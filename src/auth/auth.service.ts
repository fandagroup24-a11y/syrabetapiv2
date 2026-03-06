import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Prisma, auth_users_status } from '@prisma/client';
import { compare, hash } from 'bcrypt';
import { createHash, randomBytes } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { AccessTokenPayload } from './types/access-token-payload.type';

const AUTH_USER_SELECT = {
  id: true,
  email: true,
  phone: true,
  username: true,
  display_name: true,
  status: true,
  currency: true,
  locale: true,
  created_at: true,
  updated_at: true,
} satisfies Prisma.auth_usersSelect;

const REGISTER_WALLET_SELECT = {
  id: true,
  user_id: true,
  currency: true,
  balance_available: true,
  balance_locked: true,
  balance_bonus: true,
  created_at: true,
  updated_at: true,
} satisfies Prisma.wallet_walletsSelect;

type RequestMeta = {
  ip?: string;
  userAgent?: string;
};

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    const email = dto.email?.trim().toLowerCase() || null;
    const phone = dto.phone?.trim() || null;
    const username = dto.username?.trim() || null;

    if (!email && !phone && !username) {
      throw new BadRequestException(
        'At least one identifier is required: email, phone or username',
      );
    }

    const passwordHash = await hash(dto.password, 10);
    const currency = dto.currency?.trim().toUpperCase() || 'XOF';
    const locale = dto.locale?.trim() || 'fr';
    const displayName = dto.displayName?.trim() || null;
    const country = dto.country?.trim() || null;

    try {
      return await this.prisma.$transaction(async (tx) => {
        const user = await tx.auth_users.create({
          data: {
            email,
            phone,
            username,
            password_hash: passwordHash,
            display_name: displayName,
            country,
            currency,
            locale,
            status: auth_users_status.ACTIVE,
          },
          select: AUTH_USER_SELECT,
        });

        const wallet = await tx.wallet_wallets.create({
          data: {
            user_id: user.id,
            currency,
          },
          select: REGISTER_WALLET_SELECT,
        });

        return { user, wallet };
      });
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException('User already exists with this identifier');
      }
      throw error;
    }
  }

  async login(dto: LoginDto, meta: RequestMeta) {
    const identifier = dto.identifier.trim();
    const password = dto.password;

    const user = await this.prisma.auth_users.findFirst({
      where: {
        OR: [
          { email: identifier },
          { phone: identifier },
          { username: identifier },
        ],
      },
      select: {
        ...AUTH_USER_SELECT,
        password_hash: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (user.status !== auth_users_status.ACTIVE) {
      throw new ForbiddenException('Account is not active');
    }

    const validPassword = await compare(password, user.password_hash);
    if (!validPassword) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const refreshToken = this.generateRefreshToken();
    const refreshHash = this.hashToken(refreshToken);
    const refreshTtlDays = this.configService.get<number>(
      'JWT_REFRESH_EXPIRES_IN_DAYS',
      30,
    );
    const expiresAt = new Date(
      Date.now() + refreshTtlDays * 24 * 60 * 60 * 1000,
    );

    const session = await this.prisma.auth_sessions.create({
      data: {
        user_id: user.id,
        refresh_hash: refreshHash,
        ip_hash: meta.ip ? this.hashToken(meta.ip) : null,
        user_agent: meta.userAgent ?? null,
        expires_at: expiresAt,
      },
      select: {
        id: true,
      },
    });

    const accessToken = await this.signAccessToken({
      sub: user.id,
      sid: session.id,
      typ: 'access',
    });

    return {
      tokenType: 'Bearer',
      accessToken,
      refreshToken,
      expiresIn: this.getAccessTtlSeconds(),
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        username: user.username,
        display_name: user.display_name,
        status: user.status,
        currency: user.currency,
        locale: user.locale,
        created_at: user.created_at,
        updated_at: user.updated_at,
      },
    };
  }

  async refresh(dto: RefreshTokenDto) {
    const refreshHash = this.hashToken(dto.refreshToken.trim());
    const now = new Date();

    const session = await this.prisma.auth_sessions.findFirst({
      where: {
        refresh_hash: refreshHash,
        revoked_at: null,
        expires_at: { gt: now },
      },
      select: {
        id: true,
        user_id: true,
        auth_users: {
          select: {
            ...AUTH_USER_SELECT,
          },
        },
      },
    });

    if (!session) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    if (session.auth_users.status !== auth_users_status.ACTIVE) {
      throw new ForbiddenException('Account is not active');
    }

    const newRefreshToken = this.generateRefreshToken();
    const newRefreshHash = this.hashToken(newRefreshToken);
    const refreshTtlDays = this.configService.get<number>(
      'JWT_REFRESH_EXPIRES_IN_DAYS',
      30,
    );
    const newExpiresAt = new Date(
      Date.now() + refreshTtlDays * 24 * 60 * 60 * 1000,
    );

    await this.prisma.auth_sessions.update({
      where: { id: session.id },
      data: {
        refresh_hash: newRefreshHash,
        expires_at: newExpiresAt,
      },
    });

    const accessToken = await this.signAccessToken({
      sub: session.user_id,
      sid: session.id,
      typ: 'access',
    });

    return {
      tokenType: 'Bearer',
      accessToken,
      refreshToken: newRefreshToken,
      expiresIn: this.getAccessTtlSeconds(),
      user: session.auth_users,
    };
  }

  async logout(dto: RefreshTokenDto) {
    const refreshHash = this.hashToken(dto.refreshToken.trim());
    await this.prisma.auth_sessions.updateMany({
      where: {
        refresh_hash: refreshHash,
        revoked_at: null,
      },
      data: {
        revoked_at: new Date(),
      },
    });

    return { success: true };
  }

  async getMe(payload: AccessTokenPayload) {
    const now = new Date();

    const session = await this.prisma.auth_sessions.findUnique({
      where: { id: payload.sid },
      select: {
        user_id: true,
        revoked_at: true,
        expires_at: true,
      },
    });

    if (
      !session ||
      session.user_id !== payload.sub ||
      session.revoked_at !== null ||
      session.expires_at <= now
    ) {
      throw new UnauthorizedException('Session is no longer valid');
    }

    const user = await this.prisma.auth_users.findUnique({
      where: { id: payload.sub },
      select: AUTH_USER_SELECT,
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return user;
  }

  private async signAccessToken(payload: AccessTokenPayload) {
    const secret = this.configService.get<string>(
      'JWT_ACCESS_SECRET',
      'change-me-access-secret',
    );
    return this.jwtService.signAsync(payload, {
      secret,
      expiresIn: this.getAccessTtlSeconds(),
    });
  }

  private getAccessTtlSeconds() {
    const raw = this.configService.get<string>('JWT_ACCESS_EXPIRES_IN_SEC');
    const parsed = Number(raw);

    if (Number.isFinite(parsed) && parsed > 0) {
      return parsed;
    }

    return 900;
  }

  private hashToken(value: string) {
    return createHash('sha256').update(value).digest('hex');
  }

  private generateRefreshToken() {
    return randomBytes(48).toString('hex');
  }
}
