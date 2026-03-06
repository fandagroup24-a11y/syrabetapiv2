import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBody,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { ApproveWithdrawalDto } from './dto/approve-withdrawal.dto';
import { CreateDepositDto } from './dto/create-deposit.dto';
import { CreateWithdrawalDto } from './dto/create-withdrawal.dto';
import { ListLedgerQueryDto } from './dto/list-ledger-query.dto';
import { ListPaymentsQueryDto } from './dto/list-payments-query.dto';
import { ListWithdrawalsQueryDto } from './dto/list-withdrawals-query.dto';
import { RejectWithdrawalDto } from './dto/reject-withdrawal.dto';
import { ReverseLedgerEntryDto } from './dto/reverse-ledger-entry.dto';
import { WalletTransactionsService } from './wallet-transactions.service';

@ApiTags('Wallet Transactions')
@Controller('wallet-transactions')
export class WalletTransactionsController {
  constructor(
    private readonly walletTransactionsService: WalletTransactionsService,
  ) {}

  @Post('deposit')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a successful deposit transaction' })
  @ApiCreatedResponse({ description: 'Deposit created and wallet credited' })
  @ApiBadRequestResponse({ description: 'Invalid request payload' })
  @ApiBody({ type: CreateDepositDto })
  async createDeposit(@Body() dto: CreateDepositDto) {
    return this.walletTransactionsService.createDeposit(dto);
  }

  @Post('withdraw')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a withdrawal request' })
  @ApiCreatedResponse({ description: 'Withdrawal request created' })
  @ApiBadRequestResponse({
    description: 'Invalid request payload or insufficient balance',
  })
  @ApiBody({ type: CreateWithdrawalDto })
  async createWithdrawal(@Body() dto: CreateWithdrawalDto) {
    return this.walletTransactionsService.createWithdrawal(dto);
  }

  @Post('withdrawals/:withdrawalId/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve a requested withdrawal' })
  @ApiParam({ name: 'withdrawalId', format: 'uuid' })
  @ApiOkResponse({
    description: 'Withdrawal approved, wallet debited, ledger created',
  })
  @ApiBody({ type: ApproveWithdrawalDto })
  async approveWithdrawal(
    @Param('withdrawalId') withdrawalId: string,
    @Body() dto: ApproveWithdrawalDto,
  ) {
    return this.walletTransactionsService.approveWithdrawal(withdrawalId, dto);
  }

  @Post('withdrawals/:withdrawalId/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject a requested withdrawal' })
  @ApiParam({ name: 'withdrawalId', format: 'uuid' })
  @ApiOkResponse({ description: 'Withdrawal rejected' })
  @ApiBody({ type: RejectWithdrawalDto })
  async rejectWithdrawal(
    @Param('withdrawalId') withdrawalId: string,
    @Body() dto: RejectWithdrawalDto,
  ) {
    return this.walletTransactionsService.rejectWithdrawal(withdrawalId, dto);
  }

  @Post('ledger/:ledgerEntryId/reverse')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reverse a ledger transaction' })
  @ApiParam({ name: 'ledgerEntryId', format: 'uuid' })
  @ApiOkResponse({ description: 'Ledger reversal created and wallet adjusted' })
  @ApiBody({ type: ReverseLedgerEntryDto })
  async reverseLedgerEntry(
    @Param('ledgerEntryId') ledgerEntryId: string,
    @Body() dto: ReverseLedgerEntryDto,
  ) {
    return this.walletTransactionsService.reverseLedgerEntry(
      ledgerEntryId,
      dto,
    );
  }

  @Get('ledger')
  @ApiOperation({ summary: 'List wallet ledger entries' })
  @ApiOkResponse({ description: 'Paginated ledger list' })
  async listLedger(@Query() query: ListLedgerQueryDto) {
    return this.walletTransactionsService.listLedger(query);
  }

  @Get('payments')
  @ApiOperation({ summary: 'List wallet payments' })
  @ApiOkResponse({ description: 'Paginated payments list' })
  async listPayments(@Query() query: ListPaymentsQueryDto) {
    return this.walletTransactionsService.listPayments(query);
  }

  @Get('withdrawals')
  @ApiOperation({ summary: 'List wallet withdrawals' })
  @ApiOkResponse({ description: 'Paginated withdrawals list' })
  async listWithdrawals(@Query() query: ListWithdrawalsQueryDto) {
    return this.walletTransactionsService.listWithdrawals(query);
  }
}
