import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bills/presentation/cubit/bills_cubit.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../cubit/accounts_cubit.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AccountsCubit>().state;
    final totalBalance = state is AccountsLoaded ? state.totalBalance : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),

            const SizedBox(height: 24),

            // Balance Display Card
            _buildBalanceCard(totalBalance),

            const SizedBox(height: 24),

            // Quick Action Buttons
            _buildQuickActions(context),

            const SizedBox(height: 28),

            // Segmented Tab Control
            _buildTabSelector(),

            const SizedBox(height: 20),

            // Tab Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: IndexedStack(
                index: _selectedTab,
                children: [_buildTransactionsList(), _buildUpcomingBillsList()],
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D9488), Color(0xFF115E59), Color(0xFF0F766E)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 20, 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              ),
              const Text(
                'Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.pushNamed('connect-wallet'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Connect',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double totalBalance) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$ ${totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.add_rounded,
          label: 'Add',
          onTap: () => context.pushNamed('add-transaction'),
        ),
        const SizedBox(width: 24),
        _ActionButton(
          icon: Icons.qr_code_scanner_rounded,
          label: 'Pay',
          onTap: () {},
        ),
        const SizedBox(width: 24),
        _ActionButton(icon: Icons.send_rounded, label: 'Send', onTap: () {}),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _selectedTab == 0
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF0F172A,
                            ).withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  'Transactions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: _selectedTab == 0
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: _selectedTab == 0
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _selectedTab == 1
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF0F172A,
                            ).withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  'Upcoming Bills',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: _selectedTab == 1
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: _selectedTab == 1
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactionState = context.watch<TransactionCubit>().state;
    final transactions = transactionState is TransactionLoaded
        ? transactionState.transactions
        : <Map<String, dynamic>>[];

    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF94A3B8),
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'No transactions yet',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Add your first transaction to get started.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: transactions.take(6).map((transaction) {
        final title =
            (transaction['merchant_name'] as String?) ?? 'Transaction';
        final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
        final isIncome =
            (transaction['type'] as String? ?? 'expense') == 'income';
        final trailingText =
            '${isIncome ? '+' : '-'} \$ ${amount.toStringAsFixed(2)}';

        return _ItemTile(
          title: title,
          subtitle: transaction['transaction_date'] != null
              ? _formatDate(transaction['transaction_date'])
              : 'Recent',
          trailingText: trailingText,
          trailingColor: isIncome
              ? const Color(0xFF0D9488)
              : const Color(0xFF0F172A),
          iconWidget: Icon(
            isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: isIncome ? const Color(0xFF0D9488) : const Color(0xFFF43F5E),
            size: 20,
          ),
          iconBgColor: isIncome
              ? const Color(0xFFF0FDFA)
              : const Color(0xFFFFF1F2),
        );
      }).toList(),
    );
  }

  Widget _buildUpcomingBillsList() {
    final billsState = context.watch<BillsCubit>().state;
    final bills = billsState is BillsLoaded
        ? billsState.bills
        : <Map<String, dynamic>>[];

    final pendingBills = bills
        .where((b) => (b['status'] as String?) != 'paid')
        .toList();

    if (pendingBills.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF0D9488),
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'All caught up!',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'No upcoming bills due at this moment.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: pendingBills.take(6).map((bill) {
        final billName =
            (bill['name'] as String?) ??
            (bill['bill_name'] as String?) ??
            'Bill';
        final amount = (bill['amount'] as num?)?.toDouble() ?? 0.0;
        final dueDate = bill['due_date'] ?? 'Soon';
        final status = (bill['status'] as String?) ?? 'pending';

        return _ItemTile(
          title: billName,
          subtitle: 'Due: ${dueDate.toString()}',
          iconWidget: const Icon(
            Icons.receipt_long_rounded,
            color: Color(0xFF0D9488),
            size: 20,
          ),
          iconBgColor: const Color(0xFFF0FDFA),
          trailingText: '\$ ${amount.toStringAsFixed(2)}',
          trailingColor: const Color(0xFF0F172A),
          actionButton: _PayButton(
            onPressed: () => context.pushNamed(
              'bill-details',
              extra: {
                'billId': bill['id'],
                'billName': billName,
                'amount': amount,
                'dueDate': dueDate.toString(),
                'status': status,
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

String _formatDate(dynamic value) {
  if (value == null) return 'Recently';
  try {
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return 'Recently';
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  } catch (_) {
    return 'Recently';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: const Color(0xFF0D9488), size: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.title,
    required this.subtitle,
    required this.iconWidget,
    required this.iconBgColor,
    this.trailingText,
    this.trailingColor,
    this.actionButton,
  });

  final String title;
  final String subtitle;
  final Widget iconWidget;
  final Color iconBgColor;
  final String? trailingText;
  final Color? trailingColor;
  final Widget? actionButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (actionButton != null)
            actionButton!
          else if (trailingText != null)
            Text(
              trailingText!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: trailingColor ?? const Color(0xFF0F172A),
              ),
            ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF0FDFA),
        foregroundColor: const Color(0xFF0D9488),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFCCFBF1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Pay',
        style: TextStyle(
          color: Color(0xFF0D9488),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
