import { ApiProperty } from '@nestjs/swagger';
import { IsString, MaxLength, MinLength } from 'class-validator';

export class RejectWithdrawalDto {
  @ApiProperty({
    description: 'Rejection reason',
    example: 'KYC incomplete',
  })
  @IsString()
  @MinLength(2)
  @MaxLength(1000)
  reason!: string;
}
