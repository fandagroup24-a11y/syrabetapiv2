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

export class CreateWithdrawalDto {
  @ApiProperty({
    description: 'User id',
    format: 'uuid',
  })
  @IsUUID()
  userId!: string;

  @ApiProperty({
    description: 'Withdrawal amount',
    example: 500,
  })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount!: number;

  @ApiProperty({
    description: 'Withdrawal provider',
    example: 'wave',
  })
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  provider!: string;

  @ApiPropertyOptional({
    description: 'Withdrawal method',
    example: 'mobile_money',
  })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  method?: string;

  @ApiPropertyOptional({
    description: 'Provider reference',
    example: 'WV-654321',
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
    description: 'Reason for withdrawal',
    example: 'Cashout',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  reason?: string;
}
