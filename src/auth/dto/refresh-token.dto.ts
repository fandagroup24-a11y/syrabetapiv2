import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';

export class RefreshTokenDto {
  @ApiProperty({
    description: 'Refresh token received at login or refresh',
  })
  @IsString()
  @MinLength(20)
  refreshToken!: string;
}
