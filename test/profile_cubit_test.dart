import 'package:mono_wallet/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:mono_wallet/features/wallet/presentation/cubit/accounts_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWalletRepository implements WalletRepositoryContract {
  Map<String, dynamic>? lastProfileUpdate;

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    return {
      'full_name': 'Ada Lovelace',
      'username': '@ada',
      'avatar_url': 'https://example.com/avatar.png',
    };
  }

  @override
  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? avatarUrl,
  }) async {
    lastProfileUpdate = {
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
    };
  }

  @override
  Future<void> addAccount({
    required String name,
    required String type,
    required double balance,
    String? last4,
  }) async {}

  @override
  Future<void> deleteAccount(String accountId) async {}

  @override
  Future<List<Map<String, dynamic>>> getAccounts() async {
    return const [];
  }
}

void main() {
  test('AccountsCubit updateProfile persists profile fields', () async {
    final repository = FakeWalletRepository();
    final cubit = AccountsCubit(repository);

    await cubit.updateProfile(
      fullName: 'Grace Hopper',
      username: '@grace',
      avatarUrl: 'https://example.com/grace.png',
    );

    expect(repository.lastProfileUpdate, isNotNull);
    expect(repository.lastProfileUpdate!['full_name'], 'Grace Hopper');
    expect(repository.lastProfileUpdate!['username'], '@grace');
    expect(
      repository.lastProfileUpdate!['avatar_url'],
      'https://example.com/grace.png',
    );
  });
}
