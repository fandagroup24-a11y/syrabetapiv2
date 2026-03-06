import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';
import { PaginationQueryDto } from '../../common/dto/pagination-query.dto';

export class ListWalletsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by user id',
    format: 'uuid',
  })
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional({
    description: 'Filter by currency code (XOF, EUR, etc.)',
    minLength: 3,
    maxLength: 10,
  })
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(10)
  currency?: string;
}
