import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class ReverseLedgerEntryDto {
  @ApiPropertyOptional({
    description: 'Reversal reason',
    example: 'Manual correction',
  })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(1000)
  reason?: string;
}
