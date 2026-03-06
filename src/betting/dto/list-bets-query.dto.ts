import { betting_bets_status, betting_bets_type } from '@prisma/client';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional } from 'class-validator';
import { PaginationQueryDto } from '../../common/dto/pagination-query.dto';

export class ListBetsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by bet status',
    enum: betting_bets_status,
  })
  @IsOptional()
  @IsEnum(betting_bets_status)
  status?: betting_bets_status;

  @ApiPropertyOptional({
    description: 'Filter by bet type',
    enum: betting_bets_type,
  })
  @IsOptional()
  @IsEnum(betting_bets_type)
  type?: betting_bets_type;
}
