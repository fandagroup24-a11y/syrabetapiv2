import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';
import { PaginationQueryDto } from '../../common/dto/pagination-query.dto';

export class ListMarketsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by market status',
    example: 'OPEN',
  })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  status?: string;

  @ApiPropertyOptional({
    description: 'Filter by market type id',
    format: 'uuid',
  })
  @IsOptional()
  @IsUUID()
  marketTypeId?: string;

  @ApiPropertyOptional({
    description: 'Include selections in each market (true/false)',
    example: 'true',
  })
  @IsOptional()
  @IsString()
  @MaxLength(5)
  includeSelections?: string;
}
