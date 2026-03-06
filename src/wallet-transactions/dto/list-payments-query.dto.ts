import { wallet_payments_status } from '@prisma/client';
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

export class ListPaymentsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by user id',
    format: 'uuid',
  })
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional({
    description: 'Filter by payment status',
    enum: wallet_payments_status,
  })
  @IsOptional()
  @IsEnum(wallet_payments_status)
  status?: wallet_payments_status;

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
