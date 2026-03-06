import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class ApproveWithdrawalDto {
  @ApiPropertyOptional({
    description: 'Provider reference to attach on approval',
    example: 'WV-APPROVED-123',
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  providerRef?: string;

  @ApiPropertyOptional({
    description: 'Approval note',
    example: 'Approved by finance team',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  note?: string;
}
