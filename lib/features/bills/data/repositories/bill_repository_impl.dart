import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BillRepository {
  Future<List<Map<String, dynamic>>> getBills();

  Future<void> payBill({
    required String billId,
    required String accountId,
    required double amount,
    required String billName,
  });
}

class BillRepositoryImpl implements BillRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> getBills() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) return [];

    final response = await _supabase
        .from('bills')
        .select()
        .eq('user_id', userId)
        .order('due_date', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> payBill({
    required String billId,
    required String accountId,
    required double amount,
    required String billName,
  }) async {
    if (_supabase.auth.currentUser == null) {
      throw Exception('User not authenticated');
    }

    final sanitizedBillId = billId.trim();
    final sanitizedAccountId = accountId.trim();

    if (sanitizedBillId.isEmpty || sanitizedAccountId.isEmpty) {
      throw Exception('Bill and wallet account are required.');
    }

    // The database function reads the bill amount, fee, and name
    // directly from Supabase. Client-provided amount/name are not trusted.
    await _supabase.rpc(
      'pay_wallet_bill',
      params: {
        'p_bill_id': sanitizedBillId,
        'p_account_id': sanitizedAccountId,
      },
    );
  }
}
