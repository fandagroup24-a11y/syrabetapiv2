import {
  wallet_ledger_entries_direction,
  wallet_ledger_entries_type,
} from '@prisma/client';
import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';
import { PaginationQueryDto } from '../../common/dto/pagination-query.dto';

export class ListLedgerQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by wallet id',
    format: 'uuid',
  })
  @IsOptional()
  @IsUUID()
  walletId?: string;

  @ApiPropertyOptional({
    description: 'Filter by user id',
    format: 'uuid',
  })
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional({
    description: 'Filter by entry type',
    enum: wallet_ledger_entries_type,
  })
  @IsOptional()
  @IsEnum(wallet_ledger_entries_type)
  type?: wallet_ledger_entries_type;

  @ApiPropertyOptional({
    description: 'Filter by direction',
    enum: wallet_ledger_entries_direction,
  })
  @IsOptional()
  @IsEnum(wallet_ledger_entries_direction)
  direction?: wallet_ledger_entries_direction;

  @ApiPropertyOptional({
    description: 'Filter by currency',
    example: 'XOF',
  })
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(10)
  currency?: string;
}
