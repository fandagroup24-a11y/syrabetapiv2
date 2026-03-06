import { betting_bets_type } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsEnum,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';

export class PlaceBetDto {
  @ApiProperty({
    description: 'Bet type',
    enum: betting_bets_type,
    example: betting_bets_type.SINGLE,
  })
  @IsEnum(betting_bets_type)
  type!: betting_bets_type;

  @ApiProperty({
    description: 'Stake amount',
    example: 1000,
  })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  stake!: number;

  @ApiProperty({
    description: 'Selection ids',
    type: [String],
    example: ['uuid-1'],
  })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(20)
  @IsUUID('all', { each: true })
  selectionIds!: string[];

  @ApiPropertyOptional({
    description: 'Currency code (default XOF)',
    example: 'XOF',
  })
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(10)
  currency?: string;
}
