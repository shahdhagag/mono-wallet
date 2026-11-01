
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../profile/presentation/views/profile_view.dart';
import '../../../statistics/presentation/views/statistics_view.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../../../wallet/presentation/cubit/accounts_cubit.dart';

// ============================================================================
// HOME VIEW
// ============================================================================

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AccountsCubit>().loadAccounts();
      context.read<TransactionCubit>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountState = context.watch<AccountsCubit>().state;
    final transactionState = context.watch<TransactionCubit>().state;

    final profileName = accountState is AccountsLoaded
      ? (accountState.profile?['full_name'] as String? ?? 'Mono Wallet User')
      : 'Mono Wallet User';

    final totalBalance = accountState is AccountsLoaded
        ? accountState.totalBalance
      : 0.0;

    final transactions = transactionState is TransactionLoaded
        ? transactionState.transactions
        : <Map<String, dynamic>>[];

    final income = transactions
        .where((item) => (item['type'] as String? ?? '') == 'income')
        .fold<double>(
          0.0,
          (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0),
        );

    final expense = transactions
        .where((item) => (item['type'] as String? ?? '') == 'expense')
        .fold<double>(
          0.0,
          (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0),
        );

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate frame
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
          child: Stack(
            children: [
              // Background Gradient Glow Accent Shapes
              Positioned(
                top: -80,
                right: -40,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF0D9488).withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -50,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF14B8A6).withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: const Color(0xFF0D9488),
                        onRefresh: () async {
                          await Future.wait([
                            context.read<AccountsCubit>().loadAccounts(),
                            context.read<TransactionCubit>().loadTransactions(),
                          ]);
                        },
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(profileName, totalBalance),
                              const SizedBox(height: 18),
                              _buildSummaryCards(income, expense),
                              const SizedBox(height: 20),
                              _buildQuickActions(),
                              const SizedBox(height: 24),
                              _buildRecentTransactionsSection(transactions),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _GlassBottomNav(
                      currentIndex: _selectedIndex,
                      onTap: (index) async {
                        if (index == 0) {
                          setState(() => _selectedIndex = 0);
                          return;
                        }

                        if (index == 1) {
                          await context.pushNamed('connect-wallet');
                        } else if (index == 2) {
                          await context.pushNamed('add-transaction');
                        } else if (index == 3) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProfileView(),
                            ),
                          );
                        }

                        if (mounted) {
                          setState(() => _selectedIndex = 0);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String profileName, double totalBalance) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D9488), Color(0xFF115E59), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: Color(0xFFCCFBF1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.pushNamed('connect-wallet'),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: const Icon(
                    Icons.add_card_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'Total Net Worth',
            style: TextStyle(
              color: Color(0xFFCCFBF1),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$ ${totalBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF6EE7B7),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+2.4%',
                      style: TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expense) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Income',
            value: '+\$ ${income.toStringAsFixed(2)}',
            color: const Color(0xFF0D9488),
            bgColor: const Color(0xFFF0FDFA),
            icon: Icons.south_west_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Total Expense',
            value: '-\$ ${expense.toStringAsFixed(2)}',
            color: const Color(0xFFF43F5E),
            bgColor: const Color(0xFFFFF1F2),
            icon: Icons.north_east_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.add_rounded,
                label: 'Add Txn',
                onTap: () => context.pushNamed('add-transaction'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionTile(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Wallet',
                onTap: () => context.pushNamed('connect-wallet'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionTile(
                icon: Icons.insights_rounded,
                label: 'Analytics',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatisticsView()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection(
    List<Map<String, dynamic>> transactions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AllTransactionsView(transactions: transactions),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D9488),
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See All',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        transactions.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
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
                      'Add your first expense or income to track here.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: transactions.length > 5 ? 5 : transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final merchant =
                      (transaction['merchant_name'] as String?) ??
                      'Transaction';
                  final amount =
                      (transaction['amount'] as num?)?.toDouble() ?? 0.0;
                  final isIncome =
                      (transaction['type'] as String? ?? 'expense') == 'income';
                  final date = transaction['transaction_date'] != null
                      ? _formatDate(transaction['transaction_date'])
                      : 'Today';
                  final id = transaction['id']?.toString() ?? index.toString();

                  return Dismissible(
                    key: Key('transaction_$id'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      final transactionCubit = context.read<TransactionCubit>();
                      final accountsCubit = context.read<AccountsCubit>();
                      final deleted = await transactionCubit.deleteTransaction(
                        id,
                      );
                      if (deleted) {
                        await accountsCubit.loadAccounts();
                      }
                      return deleted;
                    },
                    onDismissed: (direction) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$merchant deleted'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: _TransactionTile(
                      title: merchant,
                      subtitle: date,
                      amount:
                          '${isIncome ? '+' : '-'} \$ ${amount.toStringAsFixed(2)}',
                      amountColor: isIncome
                          ? const Color(0xFF0D9488)
                          : const Color(0xFF0F172A),
                      icon: isIncome
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      iconColor: isIncome
                          ? const Color(0xFF0D9488)
                          : const Color(0xFFF43F5E),
                      iconBgColor: isIncome
                          ? const Color(0xFFF0FDFA)
                          : const Color(0xFFFFF1F2),
                    ),
                  );
                },
              ),
      ],
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Today';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return 'Today';
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }
}

// ============================================================================
// ALL TRANSACTIONS VIEW
// ============================================================================

class AllTransactionsView extends StatelessWidget {
  const AllTransactionsView({super.key, required this.transactions});

  final List<Map<String, dynamic>> transactions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'All Transactions',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: transactions.isEmpty
            ? const Center(
                child: Text(
                  'No transactions available',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final merchant =
                      (transaction['merchant_name'] as String?) ??
                      'Transaction';
                  final amount =
                      (transaction['amount'] as num?)?.toDouble() ?? 0.0;
                  final isIncome =
                      (transaction['type'] as String? ?? 'expense') == 'income';
                  final date = transaction['transaction_date'] != null
                      ? _formatDate(transaction['transaction_date'])
                      : 'Today';
                  final id = transaction['id']?.toString() ?? index.toString();

                  return Dismissible(
                    key: Key('all_txn_$id'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      final transactionCubit = context.read<TransactionCubit>();
                      final accountsCubit = context.read<AccountsCubit>();
                      final deleted = await transactionCubit.deleteTransaction(
                        id,
                      );
                      if (deleted) {
                        await accountsCubit.loadAccounts();
                      }
                      return deleted;
                    },
                    onDismissed: (direction) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$merchant deleted'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: _TransactionTile(
                      title: merchant,
                      subtitle: date,
                      amount:
                          '${isIncome ? '+' : '-'} \$ ${amount.toStringAsFixed(2)}',
                      amountColor: isIncome
                          ? const Color(0xFF0D9488)
                          : const Color(0xFF0F172A),
                      icon: isIncome
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      iconColor: isIncome
                          ? const Color(0xFF0D9488)
                          : const Color(0xFFF43F5E),
                      iconBgColor: isIncome
                          ? const Color(0xFFF0FDFA)
                          : const Color(0xFFFFF1F2),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Today';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return 'Today';
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }
}

// ============================================================================
// HELPER COMPONENTS
// ============================================================================

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final Color bgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
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
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF0D9488), size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(icon, color: iconColor, size: 20),
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
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = <_NavItemData>[
      const _NavItemData(icon: Icons.home_rounded, label: 'Home'),
      const _NavItemData(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Wallet',
      ),
      const _NavItemData(icon: Icons.add_circle_rounded, label: 'Add'),
      const _NavItemData(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final active = index == currentIndex;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFF0FDFA)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: active
                            ? const Color(0xFF0D9488)
                            : const Color(0xFF94A3B8),
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: active
                              ? const Color(0xFF0D9488)
                              : const Color(0xFF94A3B8),
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
