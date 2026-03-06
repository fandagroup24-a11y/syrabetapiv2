import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsNumber, IsOptional, Min } from 'class-validator';

export class UpdateDefaultRiskLimitsDto {
  @ApiPropertyOptional({
    description: 'Minimum stake allowed',
    example: 200,
    minimum: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(1)
  minStake?: number;

  @ApiPropertyOptional({
    description: 'Maximum stake allowed',
    example: 500000,
    minimum: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(1)
  maxStake?: number;

  @ApiPropertyOptional({
    description: 'Maximum potential payout allowed',
    example: 5000000,
    minimum: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(1)
  maxPayout?: number;

  @ApiPropertyOptional({
    description: 'Cooldown between bet placements in seconds',
    example: 3,
    minimum: 0,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  cooldownPlaceBetSec?: number;
}
