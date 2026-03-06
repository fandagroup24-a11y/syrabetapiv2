import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { seedSportsbook } from './sportsbook-seeder';

@Injectable()
export class DevSeedService {
  constructor(private readonly prisma: PrismaService) {}

  async seedSportsbook() {
    const result = await seedSportsbook(this.prisma);
    return {
      ...result,
      triggeredAt: new Date().toISOString(),
    };
  }
}
