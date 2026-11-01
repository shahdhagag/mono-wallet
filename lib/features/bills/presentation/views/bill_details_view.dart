import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../wallet/presentation/cubit/accounts_cubit.dart';
import '../cubit/bills_cubit.dart';

// ============================================================================
// BILL DETAILS VIEW
// ============================================================================

class BillDetailsView extends StatefulWidget {
  const BillDetailsView({
    super.key,
    this.billId,
    this.billName,
    this.amount,
    this.dueDate,
    this.status,
  });

  final String? billId;
  final String? billName;
  final double? amount;
  final String? dueDate;
  final String? status;

  @override
  State<BillDetailsView> createState() => _BillDetailsViewState();
}

class _BillDetailsViewState extends State<BillDetailsView> {
  int _selectedPaymentMethod = 0; // 0: Debit Card, 1: PayPal

  @override
  Widget build(BuildContext context) {
    final billNameValue = widget.billName ?? 'YouTube Premium';
    final dueDateValue = widget.dueDate ?? 'Feb 28, 2026';
    final amountValue = widget.amount ?? 11.99;
    const feeValue = 1.99;
    final totalValue = amountValue + feeValue;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate surrounding frame
      body: Center(
        child: Container(
          width: 420,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              const _CustomStatusBar(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0D9488), Color(0xFF115E59)],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // App Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _IconButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.of(context).maybePop(),
                            ),
                            const Expanded(
                              child: Text(
                                'Bill Details',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            _IconButton(
                              icon: Icons.more_horiz_rounded,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Main Content Card
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Service Header Card
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF0F172A,
                                        ).withValues(alpha: 0.04),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFF4B4B),
                                              Color(0xFFDC2626),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFFDC2626,
                                              ).withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              billNameValue,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Due: $dueDateValue',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          'Unpaid',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFD97706),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Payment Breakdown Card
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      _SummaryRow(
                                        label: 'Price',
                                        value:
                                            '\$ ${amountValue.toStringAsFixed(2)}',
                                      ),
                                      const SizedBox(height: 10),
                                      _SummaryRow(
                                        label: 'Service Fee',
                                        value:
                                            '\$ ${feeValue.toStringAsFixed(2)}',
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Divider(
                                          height: 1,
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      _SummaryRow(
                                        label: 'Total Amount',
                                        value:
                                            '\$ ${totalValue.toStringAsFixed(2)}',
                                        isTotal: true,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 22),

                                const Text(
                                  'Payment Method',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Payment Options
                                _PaymentMethodTile(
                                  title: 'Debit Card',
                                  subtitle: '**** **** **** 4821',
                                  icon: Icons.credit_card_rounded,
                                  iconBgColor: const Color(0xFF0D9488),
                                  isSelected: _selectedPaymentMethod == 0,
                                  onTap: () => setState(
                                    () => _selectedPaymentMethod = 0,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _PaymentMethodTile(
                                  title: 'PayPal',
                                  subtitle: 'user@email.com',
                                  icon: Icons.account_balance_wallet_rounded,
                                  iconBgColor: const Color(0xFF0284C7),
                                  isSelected: _selectedPaymentMethod == 1,
                                  onTap: () => setState(
                                    () => _selectedPaymentMethod = 1,
                                  ),
                                ),

                                const Spacer(),

                                // Pay Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: () => context.pushNamed(
                                      'bill-payment',
                                      extra: {
                                        'billId': widget.billId,
                                        'billName': billNameValue,
                                        'amount': amountValue,
                                        'dueDate': dueDateValue,
                                      },
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D9488),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shadowColor: const Color(
                                        0xFF0D9488,
                                      ).withValues(alpha: 0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Proceed to Pay',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const _BottomNavBar(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BILL PAYMENT VIEW
// ============================================================================

class BillPaymentView extends StatefulWidget {
  const BillPaymentView({
    super.key,
    this.billId,
    this.billName,
    this.amount,
    this.dueDate,
  });

  final String? billId;
  final String? billName;
  final double? amount;
  final String? dueDate;

  @override
  State<BillPaymentView> createState() => _BillPaymentViewState();
}

class _BillPaymentViewState extends State<BillPaymentView> {
  String? _selectedAccountId;
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillsCubit, BillsState>(
      listener: (context, state) {
        if (state is BillsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        if (state is BillsLoaded) {
          setState(() => _showSuccess = true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Container(
            width: 420,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                const _CustomStatusBar(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0D9488), Color(0xFF115E59)],
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _IconButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onTap: () => Navigator.of(context).maybePop(),
                              ),
                              Expanded(
                                child: Text(
                                  _showSuccess ? 'Receipt' : 'Confirm Payment',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              _IconButton(
                                icon: Icons.more_horiz_rounded,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                24,
                                20,
                                16,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _showSuccess
                                    ? _buildSuccessState()
                                    : _buildPaymentState(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentState() {
    final billNameValue = widget.billName ?? 'YouTube Premium';
    final amountValue = widget.amount ?? 11.99;
    const feeValue = 1.99;
    final totalValue = amountValue + feeValue;

    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        final accounts = state is AccountsLoaded
            ? state.accounts
            : <Map<String, dynamic>>[];

        return Column(
          key: const ValueKey('PaymentState'),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4B4B), Color(0xFFDC2626)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 14),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'You are paying for '),
                        TextSpan(
                          text: billNameValue,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const TextSpan(text: '\nvia '),
                        const TextSpan(
                          text: 'BCA OneKlik',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Breakdown
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Price',
                    value: '\$ ${amountValue.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 10),
                  _SummaryRow(
                    label: 'Service Fee',
                    value: '\$ ${feeValue.toStringAsFixed(2)}',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ),
                  _SummaryRow(
                    label: 'Total Charged',
                    value: '\$ ${totalValue.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    context.watch<BillsCubit>().state is BillsPaymentLoading
                    ? null
                    : () {
                        if ((widget.billId ?? '').isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bill data is missing.'),
                            ),
                          );
                          return;
                        }

                        if (_selectedAccountId == null ||
                            _selectedAccountId!.isEmpty) {
                          if (accounts.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please connect a wallet first.'),
                              ),
                            );
                            return;
                          }
                          _selectedAccountId = accounts.first['id'] as String?;
                        }

                        context.read<BillsCubit>().payBill(
                          billId: widget.billId!,
                          accountId: _selectedAccountId!,
                          amount: widget.amount ?? 0.0,
                          billName: widget.billName ?? 'Bill',
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: const Color(0xFF0D9488).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirm & Pay Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const _BottomNavBar(),
          ],
        );
      },
    );
  }

  Widget _buildSuccessState() {
    return Column(
      key: const ValueKey('SuccessState'),
      children: [
        const SizedBox(height: 8),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF16A34A),
            size: 42,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Payment Successful!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.billName ?? 'YouTube Premium',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),

        // Receipt Details Ticket Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: const [
              _InfoRow(label: 'Payment Method', value: 'Debit Card'),
              SizedBox(height: 10),
              _InfoRow(
                label: 'Status',
                value: 'Completed',
                valueColor: Color(0xFF16A34A),
              ),
              SizedBox(height: 10),
              _InfoRow(label: 'Time & Date', value: '08:15 AM, Feb 28'),
              SizedBox(height: 10),
              _InfoRow(label: 'Transaction ID', value: 'TXN-902138324'),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFE2E8F0)),
              ),
              _InfoRow(label: 'Amount', value: '\$ 11.99'),
              SizedBox(height: 10),
              _InfoRow(label: 'Fee', value: '\$ 1.99'),
              SizedBox(height: 10),
              _InfoRow(label: 'Total Paid', value: '\$ 13.98', isBold: true),
            ],
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text(
              'Share Receipt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0D9488),
              side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _BottomNavBar(),
      ],
    );
  }
}

// ============================================================================
// HELPER COMPONENTS
// ============================================================================

class _CustomStatusBar extends StatelessWidget {
  const _CustomStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: const Color(0xFF0D9488),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '9:41',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: const [
              Icon(
                Icons.signal_cellular_4_bar_rounded,
                size: 14,
                color: Colors.white,
              ),
              SizedBox(width: 6),
              Icon(Icons.wifi_rounded, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Icon(Icons.battery_5_bar_rounded, size: 14, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D9488)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBgColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconBgColor, size: 22),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF0D9488)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0D9488)
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(Icons.home_outlined, color: Color(0xFF94A3B8), size: 24),
          Icon(Icons.receipt_long_outlined, color: Color(0xFF94A3B8), size: 24),
          Icon(Icons.credit_card_rounded, color: Color(0xFF0D9488), size: 26),
          Icon(
            Icons.person_outline_rounded,
            color: Color(0xFF94A3B8),
            size: 24,
          ),
        ],
      ),
    );
  }
}
