import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';

export class RegisterDto {
  @ApiPropertyOptional({
    description: 'User email',
    example: 'new.user@example.com',
  })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({
    description: 'User phone number',
    example: '+2250700000000',
  })
  @IsOptional()
  @IsString()
  @MinLength(5)
  @MaxLength(50)
  phone?: string;

  @ApiPropertyOptional({
    description: 'Username',
    example: 'newuser',
  })
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(50)
  username?: string;

  @ApiProperty({
    description: 'User password',
    example: 'MyStrongPassword123!',
  })
  @IsString()
  @MinLength(6)
  password!: string;

  @ApiPropertyOptional({
    description: 'Display name',
    example: 'New User',
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  displayName?: string;

  @ApiPropertyOptional({
    description: 'Country code',
    example: 'CI',
  })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  country?: string;

  @ApiPropertyOptional({
    description: 'Preferred currency. Default is XOF.',
    example: 'XOF',
  })
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(10)
  currency?: string;

  @ApiPropertyOptional({
    description: 'Preferred locale. Default is fr.',
    example: 'fr',
  })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  locale?: string;
}
