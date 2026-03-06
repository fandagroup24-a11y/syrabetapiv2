import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Request } from 'express';

@Injectable()
export class AdminApiKeyGuard implements CanActivate {
  constructor(private readonly configService: ConfigService) {}

  canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest<Request>();
    const headerValue = request.headers['x-admin-key'];
    const providedApiKey = Array.isArray(headerValue)
      ? headerValue[0]
      : headerValue;
    const configuredApiKey = this.configService.get<string>('ADMIN_API_KEY');

    if (!configuredApiKey) {
      throw new UnauthorizedException('Admin API key is not configured');
    }

    if (!providedApiKey || providedApiKey !== configuredApiKey) {
      throw new UnauthorizedException('Invalid admin API key');
    }

    return true;
  }
}
