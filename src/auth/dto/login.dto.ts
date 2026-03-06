import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({
    description: 'Email, phone or username',
    example: 'john@example.com',
  })
  @IsString()
  @MinLength(2)
  identifier!: string;

  @ApiProperty({
    description: 'User password',
    example: 'MyStrongPassword123!',
  })
  @IsString()
  @MinLength(6)
  password!: string;
}
