import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../cubit/accounts_cubit.dart';

class ConnectWalletView extends StatefulWidget {
  const ConnectWalletView({super.key});

  @override
  State<ConnectWalletView> createState() => _ConnectWalletViewState();
}

class _ConnectWalletViewState extends State<ConnectWalletView> {
  int _selectedTab = 0;
  int _selectedServiceIndex = 0;
  bool _isSubmitting = false;

  final TextEditingController _nameController = TextEditingController(
    text: 'Shahd Youssef',
  );
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController(
    text: '500.00',
  );

  final List<Map<String, dynamic>> _serviceAccounts = const [
    {
      'name': 'Bank Link',
      'subtitle': 'Connect your primary bank account',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF0D9488),
    },
    {
      'name': 'Microdeposits',
      'subtitle': 'Verification within 3-5 business days',
      'icon': Icons.attach_money_rounded,
      'color': Color(0xFF64748B),
    },
    {
      'name': 'PayPal',
      'subtitle': 'Connect your PayPal wallet',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFF003087),
    },
    {
      'name': 'Netflix',
      'subtitle': 'Automated recurring billing account',
      'icon': Icons.play_circle_fill_rounded,
      'color': Color(0xFFE50914),
    },
    {
      'name': 'Spotify',
      'subtitle': 'Automated subscription account',
      'icon': Icons.music_note_rounded,
      'color': Color(0xFF1DB954),
    },
    {
      'name': 'Internet Utility',
      'subtitle': 'Home utility provider',
      'icon': Icons.router_rounded,
      'color': Color(0xFF4F46E5),
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _cvcController.dispose();
    _expiryController.dispose();
    _zipController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submitAccount() {
    if (_isSubmitting) return;

    final balanceText = _balanceController.text.trim();
    final balance = double.tryParse(balanceText) ?? 0.0;

    if (_selectedTab == 0) {
      final name = _nameController.text.trim();
      final cardNumber = _cardNumberController.text.trim();

      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the name on the card.')),
        );
        return;
      }

      final last4 = cardNumber.length >= 4
          ? cardNumber.substring(cardNumber.length - 4)
          : null;
      final currentState = context.read<AccountsCubit>().state;
      final accounts = currentState is AccountsLoaded
          ? currentState.accounts
          : const <Map<String, dynamic>>[];
      final duplicate = accounts.any(
        (account) =>
            account['type'] == 'card' &&
            account['name'] == name &&
            (last4 == null || account['last4'] == last4),
      );
      if (duplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This card is already connected. Edit the details or add a different card.',
            ),
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      context.read<AccountsCubit>().createAccount(
        name: name,
        type: 'card',
        balance: balance,
        last4: last4,
      );
      return;
    }

    final service = _serviceAccounts[_selectedServiceIndex];
    setState(() => _isSubmitting = true);
    context.read<AccountsCubit>().createAccount(
      name: service['name'] as String,
      type: 'service',
      balance: balance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountsCubit, AccountsState>(
      listener: (context, state) {
        if (state is AccountsError) {
          if (_isSubmitting && mounted) setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          return;
        }

        if (state is AccountsLoaded && _isSubmitting) {
          _nameController.clear();
          _cardNumberController.clear();
          _cvcController.clear();
          _expiryController.clear();
          _zipController.clear();
          _balanceController.text = '500.00';
          setState(() => _isSubmitting = false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<AccountsCubit, AccountsState>(
                builder: (context, state) {
                  final accounts = state is AccountsLoaded
                      ? state.accounts
                      : <Map<String, dynamic>>[];

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTabSwitcher(),
                        const SizedBox(height: 20),
                        IndexedStack(
                          index: _selectedTab,
                          children: [_buildCardsTab(), _buildAccountsTab()],
                        ),
                        if (accounts.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          const Text(
                            'Saved Accounts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...accounts.map((account) {
                            final name =
                                (account['name'] as String?) ?? 'Account';
                            final type =
                                (account['type'] as String?) ?? 'account';
                            final balance =
                                (account['balance'] as num?)?.toDouble() ?? 0.0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0F172A,
                                    ).withValues(alpha: 0.02),
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
                                      color: const Color(0xFFF0FDFA),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Color(0xFF0D9488),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color(0xFF0F172A),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          type.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF64748B),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$ ${balance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF0D9488),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () async {
                                      final accountId =
                                          ((account['id'] ??
                                                      account['account_id']) ??
                                                  '')
                                              .toString()
                                              .trim();
                                      if (accountId.isEmpty) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'This account cannot be removed right now.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (!context.mounted) return;
                                      try {
                                        await context
                                            .read<AccountsCubit>()
                                            .deleteAccount(accountId);
                                        if (context.mounted) {
                                          await context
                                              .read<TransactionCubit>()
                                              .loadTransactions();
                                        }
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Account removed successfully.',
                                            ),
                                          ),
                                        );
                                      } catch (error) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(error.toString()),
                                          ),
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF1F2),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFFECDD3),
                                        ),
                                      ),
                                      child: const Text(
                                        'Remove',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFF43F5E),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isSubmitting
                          ? 'Saving...'
                          : _selectedTab == 0
                          ? 'Connect Debit Card'
                          : 'Connect Account',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
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
              ),
              const Text(
                'Connect Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
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
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _selectedTab == 0
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  'Cards',
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
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _selectedTab == 1
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  'Accounts',
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

  Widget _buildCardsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: _cardNumberController,
          builder: (context, value, _) {
            final text = value.text.replaceAll(' ', '');
            final formatted = text.isEmpty
                ? '•••• •••• •••• ••••'
                : text
                      .replaceAllMapped(
                        RegExp(r'.{4}'),
                        (match) => '${match.group(0)} ',
                      )
                      .trim();

            return Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D9488),
                    Color(0xFF115E59),
                    Color(0xFF0F172A),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DEBIT CARD',
                        style: TextStyle(
                          color: Color(0xFFCCFBF1),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'mono',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 42,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE047).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                  ),
                  Text(
                    formatted,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _nameController,
                        builder: (context, val, _) {
                          return Text(
                            val.text.isEmpty
                                ? 'CARDHOLDER NAME'
                                : val.text.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: _expiryController,
                        builder: (context, val, _) {
                          return Text(
                            val.text.isEmpty ? 'MM/YY' : val.text,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Card Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ensure this card is registered under your legal primary account.',
          style: TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        _buildCustomTextField(
          controller: _nameController,
          label: 'Cardholder Name',
          hintText: 'e.g. Shahd Youssef',
        ),
        const SizedBox(height: 14),
        _buildCustomTextField(
          controller: _balanceController,
          label: 'Initial Balance (\$)',
          hintText: '500.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildCustomTextField(
                controller: _cardNumberController,
                label: 'Card Number',
                hintText: '4111 2222 3333 4444',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildCustomTextField(
                controller: _cvcController,
                label: 'CVC / CVV',
                hintText: '123',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildCustomTextField(
                controller: _expiryController,
                label: 'Expiry Date',
                hintText: 'MM/YY',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildCustomTextField(
                controller: _zipController,
                label: 'ZIP Code',
                hintText: '10001',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountsTab() {
    return Column(
      children: [
        _buildCustomTextField(
          controller: _balanceController,
          label: 'Initial Account Balance (\$)',
          hintText: '500.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 18),
        ..._serviceAccounts.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = _selectedServiceIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedServiceIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0D9488)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
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
                        color: (item['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFF0D9488)
                                  : const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0D9488)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0D9488)
                              : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF0D9488),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
        ),
      ),
    );
  }
}
