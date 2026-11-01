import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../../../wallet/presentation/cubit/accounts_cubit.dart';
import '../cubit/bills_cubit.dart';

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          return;
        }

        if (state is BillsPaymentSuccess) {
          context.read<AccountsCubit>().loadAccounts();
          context.read<TransactionCubit>().loadTransactions();
          setState(() => _showSuccess = true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFD9D9D9),
        body: Center(
          child: SizedBox(
            width: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
              ),
              child: Column(
                children: [
                  _StatusBar(),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF2D8A85), Color(0xFF2D8A85)],
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _showSuccess
                                        ? 'Bill Payment'
                                        : 'Bill Payment',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.more_horiz_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                18,
                                18,
                                10,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(28),
                                  topRight: Radius.circular(28),
                                ),
                              ),
                              child: _showSuccess
                                  ? _buildSuccessState()
                                  : _buildPaymentState(),
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
      ),
    );
  }

  Widget _buildPaymentState() {
    final billNameValue = widget.billName ?? 'Youtube Premium';
    final amountValue = widget.amount ?? 11.99;
    final feeValue = 1.99;
    final totalValue = amountValue + feeValue;

    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        final accounts = state is AccountsLoaded
            ? state.accounts
            : <Map<String, dynamic>>[];
        final isPaying =
            context.watch<BillsCubit>().state is BillsPaymentLoading;

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFE5252),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'You will pay $billNameValue\nfor one month with BCA OneKlik',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1A1A1A),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Price',
                  style: TextStyle(fontSize: 14, color: Color(0xFF7D7D7D)),
                ),
                Text(
                  '\$ 11.99',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Fee',
                  style: TextStyle(fontSize: 14, color: Color(0xFF7D7D7D)),
                ),
                Text(
                  '\$ 1.99',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const Divider(height: 26, color: Color(0xFFE3E3E3)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 14, color: Color(0xFF7D7D7D)),
                ),
                Text(
                  '\$ ${totalValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isPaying
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
                  backgroundColor: const Color(0xFF2E8C85),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Confirm and Pay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const _BottomNavBar(),
          ],
        );
      },
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 18),
        Container(
          width: 62,
          height: 62,
          decoration: const BoxDecoration(
            color: Color(0xFF2E8C85),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 14),
        const Text(
          'Payment Successfully',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.billName ?? 'Youtube Premium',
          style: const TextStyle(fontSize: 13, color: Color(0xFF7D7D7D)),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: const [
              _InfoRow(label: 'Payment method', value: 'Debit Card'),
              SizedBox(height: 10),
              _InfoRow(label: 'Status', value: 'Completed'),
              SizedBox(height: 10),
              _InfoRow(label: 'Time', value: '08:15 AM'),
              SizedBox(height: 10),
              _InfoRow(label: 'Date', value: 'Feb 28, 2022'),
              SizedBox(height: 10),
              _InfoRow(label: 'Transaction ID', value: '209213832472...'),
              SizedBox(height: 10),
              _InfoRow(label: 'Price', value: '\$ 11.99'),
              SizedBox(height: 10),
              _InfoRow(label: 'Fee', value: '- \$ 1.99'),
              SizedBox(height: 12),
              Divider(height: 18, color: Color(0xFFE3E3E3)),
              SizedBox(height: 6),
              _InfoRow(label: 'Total', value: '\$ 13.98'),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E8C85),
              side: const BorderSide(color: Color(0xFF2E8C85), width: 1.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Share Receipt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const _BottomNavBar(),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF7D7D7D)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      color: const Color(0xFF2D8A85),
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
              SizedBox(width: 4),
              Icon(Icons.wifi_rounded, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Icon(Icons.battery_5_bar_rounded, size: 14, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(Icons.home_outlined, color: Color(0xFF7D7D7D), size: 26),
          Icon(Icons.list_alt_rounded, color: Color(0xFF7D7D7D), size: 26),
          Icon(Icons.credit_card_rounded, color: Color(0xFF2E8C85), size: 30),
          Icon(
            Icons.person_outline_rounded,
            color: Color(0xFF7D7D7D),
            size: 26,
          ),
        ],
      ),
    );
  }
}
