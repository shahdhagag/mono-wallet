import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TransactionRepository {
  Future<List<Map<String, dynamic>>> getTransactions();

  Future<void> addTransaction({
    required String accountId,
    required String merchantName,
    required double amount,
    required String type,
    String? categoryId,
  });

  Future<void> addTransactions({
    required String accountId,
    required List<
      ({String merchantName, double amount, String type, String? categoryId})
    >
    transactions,
  });

  Future<void> deleteTransaction(String transactionId);
}

class TransactionRepositoryImpl implements TransactionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  static String? normalizeCategoryId(String? rawCategoryId) {
    final value = rawCategoryId?.trim();

    if (value == null || value.isEmpty) return null;

    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );

    return uuidPattern.hasMatch(value) ? value : null;
  }

  static void validateTransactionInput({
    required String merchantName,
    required double amount,
    required String type,
  }) {
    if (merchantName.trim().isEmpty) {
      throw Exception('Merchant name cannot be empty.');
    }

    if (!amount.isFinite || amount <= 0) {
      throw Exception('Transaction amount must be greater than zero.');
    }

    if (type != 'income' && type != 'expense') {
      throw Exception('Invalid transaction type.');
    }
  }

  void _ensureAuthenticated() {
    if (_supabase.auth.currentUser == null) {
      throw Exception('User not authenticated');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) return [];

    final response = await _supabase
        .from('transactions')
        .select('*, accounts(name), categories(name)')
        .eq('user_id', userId)
        .order('transaction_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> addTransaction({
    required String accountId,
    required String merchantName,
    required double amount,
    required String type,
    String? categoryId,
  }) async {
    await addTransactions(
      accountId: accountId,
      transactions: [
        (
          merchantName: merchantName,
          amount: amount,
          type: type,
          categoryId: categoryId,
        ),
      ],
    );
  }

  @override
  Future<void> addTransactions({
    required String accountId,
    required List<
      ({String merchantName, double amount, String type, String? categoryId})
    >
    transactions,
  }) async {
    _ensureAuthenticated();

    final sanitizedAccountId = accountId.trim();

    if (sanitizedAccountId.isEmpty) {
      throw Exception('Please select a wallet account first.');
    }

    if (transactions.isEmpty) {
      throw Exception('No transactions to save.');
    }

    final payload = transactions.map((transaction) {
      final merchantName = transaction.merchantName.trim();

      validateTransactionInput(
        merchantName: merchantName,
        amount: transaction.amount,
        type: transaction.type,
      );

      return {
        'merchantName': merchantName,
        'amount': transaction.amount,
        'type': transaction.type,
        'categoryId': normalizeCategoryId(transaction.categoryId),
      };
    }).toList();

    await _supabase.rpc(
      'create_wallet_transactions',
      params: {'p_account_id': sanitizedAccountId, 'p_transactions': payload},
    );
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    if (_supabase.auth.currentUser == null) {
      throw Exception('User not authenticated');
    }

    final id = transactionId.trim();

    if (id.isEmpty) {
      throw Exception('Transaction id is missing.');
    }

    await _supabase.rpc(
      'delete_wallet_transaction',
      params: {'p_transaction_id': id},
    );
  }
}
