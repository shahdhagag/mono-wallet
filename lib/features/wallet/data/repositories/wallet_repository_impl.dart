import 'package:supabase_flutter/supabase_flutter.dart';

abstract class WalletRepositoryContract {
  Future<Map<String, dynamic>?> getUserProfile();

  Future<List<Map<String, dynamic>>> getAccounts();

  Future<void> addAccount({
    required String name,
    required String type,
    required double balance,
    String? last4,
  });

  Future<void> deleteAccount(String accountId);

  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? avatarUrl,
  });
}

class WalletRepositoryImpl implements WalletRepositoryContract {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getAccounts() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('accounts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> addAccount({
    required String name,
    required String type,
    required double balance,
    String? last4,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _supabase.from('accounts').insert({
      'user_id': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'last4': last4,
    });
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final id = accountId.trim();
    if (id.isEmpty) {
      throw Exception('Account id is missing.');
    }

    try {
      await _supabase
          .from('transactions')
          .delete()
          .eq('account_id', id)
          .eq('user_id', userId);

      await _supabase
          .from('accounts')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } on PostgrestException catch (error) {
      throw Exception('Could not delete account: ${error.message}');
    }
  }

  @override
  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? avatarUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final data = <String, dynamic>{};
    if (fullName != null && fullName.trim().isNotEmpty) {
      data['full_name'] = fullName.trim();
    }
    if (username != null && username.trim().isNotEmpty) {
      data['username'] = username.trim();
    }
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      data['avatar_url'] = avatarUrl.trim();
    }

    if (data.isEmpty) {
      return;
    }

    await _supabase.from('profiles').update(data).eq('id', userId);
  }
}
