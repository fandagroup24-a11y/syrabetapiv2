import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';

export class CreateDepositDto {
  @ApiProperty({
    description: 'User id',
    format: 'uuid',
  })
  @IsUUID()
  userId!: string;

  @ApiProperty({
    description: 'Deposit amount',
    example: 1000,
  })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount!: number;

  @ApiProperty({
    description: 'Payment provider',
    example: 'orange_money',
  })
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  provider!: string;

  @ApiPropertyOptional({
    description: 'Payment method',
    example: 'deposit',
  })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  method?: string;

  @ApiPropertyOptional({
    description: 'Provider reference',
    example: 'OM-123456',
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  providerRef?: string;

  @ApiPropertyOptional({
    description: 'Currency code (default: XOF)',
    example: 'XOF',
  })
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(10)
  currency?: string;

  @ApiPropertyOptional({
    description: 'Operation description',
    example: 'Initial wallet funding',
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;
}
