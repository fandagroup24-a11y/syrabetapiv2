import { auth_users_status } from '@prisma/client';
import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MinLength,
} from 'class-validator';
import { PaginationQueryDto } from '../../common/dto/pagination-query.dto';

export class ListUsersQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by user status',
    enum: auth_users_status,
  })
  @IsOptional()
  @IsEnum(auth_users_status)
  status?: auth_users_status;

  @ApiPropertyOptional({
    description: 'Search by email, phone, username or display name',
    minLength: 2,
  })
  @IsOptional()
  @IsString()
  @MinLength(2)
  search?: string;

  @ApiPropertyOptional({
    description: 'Filter by user id',
    format: 'uuid',
  })
  @IsOptional()
  @IsUUID()
  userId?: string;
}
