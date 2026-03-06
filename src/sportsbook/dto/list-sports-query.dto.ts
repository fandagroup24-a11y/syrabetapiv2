import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import { PaginationQueryDto } from '../../common/dto/pagination-query.dto';

export class ListSportsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by sport status',
    example: 'ACTIVE',
  })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  status?: string;

  @ApiPropertyOptional({
    description: 'Search by sport code or name',
    minLength: 2,
  })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  search?: string;
}
