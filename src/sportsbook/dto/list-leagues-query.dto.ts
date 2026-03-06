import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';
import { PaginationQueryDto } from '../../common/dto/pagination-query.dto';

export class ListLeaguesQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by sport id',
    format: 'uuid',
  })
  @IsOptional()
  @IsUUID()
  sportId?: string;

  @ApiPropertyOptional({
    description: 'Filter by country id',
    format: 'uuid',
  })
  @IsOptional()
  @IsUUID()
  countryId?: string;

  @ApiPropertyOptional({
    description: 'Filter by league status',
    example: 'ACTIVE',
  })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  status?: string;

  @ApiPropertyOptional({
    description: 'Search by league name',
    minLength: 2,
  })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  search?: string;
}
