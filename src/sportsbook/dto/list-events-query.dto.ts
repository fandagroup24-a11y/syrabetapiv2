import { sportsbook_events_status } from '@prisma/client';
import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsDateString,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';
import { PaginationQueryDto } from '../../common/dto/pagination-query.dto';

export class ListEventsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by sport id',
    format: 'uuid',
  })
  @IsOptional()
  @IsUUID()
  sportId?: string;

  @ApiPropertyOptional({
    description: 'Filter by league id',
    format: 'uuid',
  })
  @IsOptional()
  @IsUUID()
  leagueId?: string;

  @ApiPropertyOptional({
    description: 'Filter by event status',
    enum: sportsbook_events_status,
  })
  @IsOptional()
  @IsEnum(sportsbook_events_status)
  status?: sportsbook_events_status;

  @ApiPropertyOptional({
    description: 'Filter by start date (inclusive), ISO datetime',
    example: '2026-03-05T00:00:00.000Z',
  })
  @IsOptional()
  @IsDateString()
  dateFrom?: string;

  @ApiPropertyOptional({
    description: 'Filter by end date (inclusive), ISO datetime',
    example: '2026-03-08T23:59:59.000Z',
  })
  @IsOptional()
  @IsDateString()
  dateTo?: string;

  @ApiPropertyOptional({
    description: 'Quick filter: true returns LIVE events, false excludes LIVE',
    example: 'true',
  })
  @IsOptional()
  @IsString()
  @MaxLength(5)
  live?: string;

  @ApiPropertyOptional({
    description: 'Search by event name',
    minLength: 2,
  })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(160)
  search?: string;
}
