import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/helpers.dart';
import '../../data/services/gemini_expense_parser.dart';
import '../../../wallet/presentation/cubit/accounts_cubit.dart';
import '../cubit/transaction_cubit.dart';
import '../widgets/voice_expense_input.dart';

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({super.key});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedType = 'expense';
  String? _selectedAccountId;
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = const [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final List<Map<String, dynamic>> fallbackCategories = [
      {'id': 'fallback_food', 'name': 'Food', 'icon': Icons.fastfood_rounded},
      {'id': 'fallback_transport', 'name': 'Transport', 'icon': Icons.directions_car_rounded},
      {'id': 'fallback_shopping', 'name': 'Shopping', 'icon': Icons.shopping_bag_rounded},
      {'id': 'fallback_bills', 'name': 'Bills', 'icon': Icons.receipt_long_rounded},
      {'id': 'fallback_income', 'name': 'Income', 'icon': Icons.trending_up_rounded},
      {'id': 'fallback_other', 'name': 'Other', 'icon': Icons.category_rounded},
    ];

    try {
      final dynamic response = await Supabase.instance.client
          .from('categories')
          .select()
          .order('name', ascending: true);

      if (!mounted) return;

        final List<Map<String, dynamic>> categories =
          List<Map<String, dynamic>>.from(response);
      setState(() {
        _categories = categories.isNotEmpty ? categories : fallbackCategories;
        _selectedCategoryId = _categories.isNotEmpty
            ? _categories.first['id'] as String
            : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = fallbackCategories;
        _selectedCategoryId = fallbackCategories.first['id'] as String;
      });
    }
  }

  IconData _getCategoryIcon(String name) {
    final String lower = name.toLowerCase();
    if (lower.contains('food') || lower.contains('restaur') || lower.contains('cafe')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('transport') || lower.contains('car') || lower.contains('uber')) {
      return Icons.directions_car_rounded;
    }
    if (lower.contains('shop') || lower.contains('cloth')) {
      return Icons.shopping_bag_rounded;
    }
    if (lower.contains('bill') || lower.contains('util')) {
      return Icons.receipt_long_rounded;
    }
    if (lower.contains('income') || lower.contains('salary')) {
      return Icons.trending_up_rounded;
    }
    return Icons.category_rounded;
  }

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    String? prefixText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _showVoiceConfirmation(List<VoiceExpense> expenses) async {
    final List<VoiceExpense> editableExpenses = List<VoiceExpense>.from(expenses);
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          top: 24,
          right: 20,
          bottom: MediaQuery.viewInsetsOf(dialogContext).bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Confirm Parsed Expenses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(dialogContext, false),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: editableExpenses.length,
                    separatorBuilder: (BuildContext context, int index) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Color(0xFFE2E8F0), height: 1),
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final VoiceExpense expense = editableExpenses[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                TextFormField(
                                  initialValue: expense.item,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  decoration: const InputDecoration(
                                    labelText: 'Item Name',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  onChanged: (String value) => editableExpenses[index] =
                                      editableExpenses[index].copyWith(item: value),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                    initialValue: _categories.any((Map<String, dynamic> c) => c['name'] == expense.category)
                                      ? expense.category
                                      : null,
                                  hint: const Text('Select Category', style: TextStyle(fontSize: 12)),
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  items: _categories.map((Map<String, dynamic> category) {
                                    final String name = category['name'] as String? ?? 'Other';
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name, style: const TextStyle(fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      editableExpenses[index] =
                                          editableExpenses[index].copyWith(category: value);
                                    }
                                    setDialogState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              initialValue: expense.amount.toStringAsFixed(2),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0D9488),
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Amount (\$)',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              onChanged: (String value) {
                                final double? amount = double.tryParse(value);
                                if (amount != null) {
                                  editableExpenses[index] =
                                      editableExpenses[index].copyWith(amount: amount);
                                }
                              },
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: () => setDialogState(() => editableExpenses.removeAt(index)),
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF43F5E), size: 22),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: editableExpenses.isEmpty ? null : () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Confirm & Save', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    final String? accountId = _selectedAccountId;
    if (accountId == null || accountId.isEmpty) {
      context.showPremiumSnackBar('Please choose a wallet first.', icon: Icons.wallet_rounded, backgroundColor: const Color(0xFFF59E0B));
      return;
    }

    final List<({String merchantName, double amount, String type, String? categoryId})> transactions = editableExpenses
        .where((VoiceExpense e) => e.item.trim().isNotEmpty && e.amount > 0)
        .map((VoiceExpense e) => (
              merchantName: e.item.trim(),
              amount: e.amount,
              type: e.type,
              categoryId: _categoryIdForName(e.category),
            ))
        .toList();

    if (transactions.isNotEmpty && !_isSaving) {
      setState(() => _isSaving = true);
      context.read<TransactionCubit>().createTransactions(
            accountId: accountId,
            transactions: transactions,
          );
    }
  }

  String? _categoryIdForName(String name) {
    final String normalized = name.trim().toLowerCase();
    for (final Map<String, dynamic> category in _categories) {
      final String categoryName = (category['name'] as String? ?? '').trim().toLowerCase();
      if (categoryName == normalized || categoryName.contains(normalized) || normalized.contains(categoryName)) {
        return category['id'] as String?;
      }
    }
    for (final Map<String, dynamic> category in _categories) {
      if ((category['name'] as String? ?? '').trim().toLowerCase() == 'other') {
        return category['id'] as String?;
      }
    }
    return _categories.isNotEmpty ? _categories.first['id'] as String? : null;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wallet_rounded, size: 56, color: Color(0xFF0D9488)),
            const SizedBox(height: 16),
            const Text(
              'No Accounts Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please add a wallet account before logging transactions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionCubit, TransactionState>(
      listener: (BuildContext context, TransactionState state) {
        if (state is TransactionError) {
          if (mounted) setState(() => _isSaving = false);
          context.showPremiumSnackBar(
            state.message,
            icon: Icons.error_outline_rounded,
            backgroundColor: const Color(0xFFF43F5E),
          );
          return;
        }

        if (state is TransactionLoaded && _isSaving) {
          setState(() => _isSaving = false);
          context.read<AccountsCubit>().loadAccounts();
          context.showPremiumSnackBar(
            'Transaction saved successfully.',
            icon: Icons.check_circle_rounded,
            backgroundColor: const Color(0xFF0D9488),
          );
          if (context.canPop()) context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SafeArea(
                top: false,
                child: BlocBuilder<AccountsCubit, AccountsState>(
                  builder: (BuildContext context, AccountsState state) {
                    final List<Map<String, dynamic>> accounts = state is AccountsLoaded
                        ? state.accounts
                      : <Map<String, dynamic>>[];

                    if (accounts.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    if (_selectedAccountId == null && accounts.isNotEmpty) {
                      _selectedAccountId = accounts.first['id'] as String?;
                    }

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      children: [
                        const Text(
                          'New Transaction',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Track an income or expense effortlessly',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        VoiceExpenseInput(
                          onExpensesParsed: _showVoiceConfirmation,
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                initialValue: _selectedAccountId,
                                decoration: _buildInputDecoration(
                                  label: 'Wallet Account',
                                  icon: Icons.account_balance_wallet_rounded,
                                ),
                                items: accounts.map((Map<String, dynamic> account) {
                                  final String name = account['name'] as String? ?? 'Account';
                                  final String type = (account['type'] as String? ?? 'card').toUpperCase();
                                  return DropdownMenuItem<String>(
                                    value: account['id'] as String,
                                    child: Text(
                                      '$name ($type)',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) =>
                                    setState(() => _selectedAccountId = value),
                              ),
                              const SizedBox(height: 16),

                              const Text(
                                'Category',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 85,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _categories.length,
                                  separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 8),
                                  itemBuilder: (BuildContext context, int index) {
                                    final Map<String, dynamic> cat = _categories[index];
                                    final String catId = cat['id'] as String;
                                    final String catName = cat['name'] as String? ?? 'Other';
                                    final bool isSelected = _selectedCategoryId == catId;

                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedCategoryId = catId),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 72,
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _getCategoryIcon(catName),
                                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                                              size: 22,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              catName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected ? Colors.white : const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _merchantController,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                                decoration: _buildInputDecoration(
                                  label: 'Merchant / Title',
                                  hint: 'e.g. Starbucks, Grocery Store',
                                  icon: Icons.storefront_rounded,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                                decoration: _buildInputDecoration(
                                  label: 'Amount',
                                  hint: '0.00',
                                  prefixText: '\$ ',
                                  icon: Icons.attach_money_rounded,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _TypeChip(
                                        label: 'Expense',
                                        icon: Icons.arrow_downward_rounded,
                                        selected: _selectedType == 'expense',
                                        color: const Color(0xFFF43F5E),
                                        onTap: () => setState(() => _selectedType = 'expense'),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _TypeChip(
                                        label: 'Income',
                                        icon: Icons.arrow_upward_rounded,
                                        selected: _selectedType == 'income',
                                        color: const Color(0xFF0D9488),
                                        onTap: () => setState(() => _selectedType = 'income'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: _isSaving
                                      ? null
                                      : () {
                                          final String merchantName = _merchantController.text.trim();
                                          final String amountText = _amountController.text.trim();
                                          final double amount = double.tryParse(amountText) ?? 0.0;

                                          if (_selectedAccountId == null || _selectedAccountId!.isEmpty) {
                                            context.showPremiumSnackBar(
                                              'Please select a wallet first.',
                                              icon: Icons.wallet_rounded,
                                              backgroundColor: const Color(0xFFF59E0B),
                                            );
                                            return;
                                          }

                                          if (merchantName.isEmpty || amount <= 0) {
                                            context.showPremiumSnackBar(
                                              'Please enter a valid title and amount.',
                                              icon: Icons.info_outline_rounded,
                                              backgroundColor: const Color(0xFFF59E0B),
                                            );
                                            return;
                                          }

                                          setState(() => _isSaving = true);
                                          context.read<TransactionCubit>().createTransaction(
                                                accountId: _selectedAccountId!,
                                                merchantName: merchantName,
                                                amount: amount,
                                                type: _selectedType,
                                                categoryId: _selectedCategoryId,
                                              );
                                        },
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text(
                                          'Save Transaction',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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
                onPressed: () => context.pop(),
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
                'Add Transaction',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}