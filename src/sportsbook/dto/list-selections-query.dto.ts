import { sportsbook_selections_result } from '@prisma/client';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import { PaginationQueryDto } from '../../common/dto/pagination-query.dto';

export class ListSelectionsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by selection status',
    example: 'OPEN',
  })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  status?: string;

  @ApiPropertyOptional({
    description: 'Filter by selection result',
    enum: sportsbook_selections_result,
  })
  @IsOptional()
  @IsEnum(sportsbook_selections_result)
  result?: sportsbook_selections_result;
}
