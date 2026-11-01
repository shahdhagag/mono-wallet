import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/wallet_repository_impl.dart';

abstract class AccountsState {}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  AccountsLoaded({
    required this.accounts,
    required this.totalBalance,
    this.profile,
  });

  final List<Map<String, dynamic>> accounts;
  final double totalBalance;
  final Map<String, dynamic>? profile;
}

class AccountsError extends AccountsState {
  AccountsError(this.message);

  final String message;
}

class AccountsCubit extends Cubit<AccountsState> {
  AccountsCubit(this._repository) : super(AccountsInitial());

  final WalletRepositoryContract _repository;

  void clear() {
    emit(AccountsInitial());
  }

  Future<void> loadProfile() async {
    final current = state is AccountsLoaded ? state as AccountsLoaded : null;
    try {
      final profile = await _repository.getUserProfile();
      final accounts = current?.accounts ?? <Map<String, dynamic>>[];
      final totalBalance = current?.totalBalance ?? 0.0;

      emit(
        AccountsLoaded(
          accounts: accounts,
          totalBalance: totalBalance,
          profile: profile,
        ),
      );
    } catch (error) {
      emit(AccountsError(error.toString()));
      if (current != null) emit(current);
    }
  }

  Future<void> loadAccounts() async {
    final current = state is AccountsLoaded ? state as AccountsLoaded : null;
    if (current == null) {
      emit(AccountsLoading());
    }

    try {
      final accounts = await _repository.getAccounts();
      final profile = await _repository.getUserProfile();
      final totalBalance = accounts.fold<double>(
        0.0,
        (sum, item) => sum + (item['balance'] as num? ?? 0).toDouble(),
      );

      emit(
        AccountsLoaded(
          accounts: accounts,
          totalBalance: totalBalance,
          profile: profile,
        ),
      );
    } catch (error) {
      emit(AccountsError(error.toString()));
      if (current != null) emit(current);
    }
  }

  Future<void> createAccount({
    required String name,
    required String type,
    required double balance,
    String? last4,
  }) async {
    final current = state is AccountsLoaded ? state as AccountsLoaded : null;
    try {
      await _repository.addAccount(
        name: name,
        type: type,
        balance: balance,
        last4: last4,
      );
      await loadAccounts();
    } catch (error) {
      emit(AccountsError(error.toString()));
      if (current != null) emit(current);
    }
  }

  Future<void> deleteAccount(String accountId) async {
    final trimmedId = accountId.trim();
    if (trimmedId.isEmpty) {
      emit(AccountsError('Account id is missing.'));
      return;
    }

    final current = state is AccountsLoaded ? state as AccountsLoaded : null;
    final previousAccounts = current?.accounts ?? <Map<String, dynamic>>[];

    if (current != null) {
      final updatedAccounts = previousAccounts
          .where(
            (account) =>
                ((account['id'] ?? account['account_id']) ?? '')
                    .toString()
                    .trim() !=
                trimmedId,
          )
          .toList();
      final updatedTotal = updatedAccounts.fold<double>(
        0.0,
        (sum, item) => sum + ((item['balance'] as num?)?.toDouble() ?? 0.0),
      );

      emit(
        AccountsLoaded(
          accounts: updatedAccounts,
          totalBalance: updatedTotal,
          profile: current.profile,
        ),
      );
    }

    try {
      await _repository.deleteAccount(trimmedId);
      await loadAccounts();
    } catch (error) {
      emit(AccountsError(error.toString()));
      if (current != null) {
        emit(
          AccountsLoaded(
            accounts: previousAccounts,
            totalBalance: current.totalBalance,
            profile: current.profile,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? avatarUrl,
  }) async {
    final current = state is AccountsLoaded ? state as AccountsLoaded : null;
    if (current != null) {
      final nextProfile = <String, dynamic>{
        if (current.profile != null) ...current.profile!,
        if (fullName != null && fullName.trim().isNotEmpty)
          'full_name': fullName.trim(),
        if (username != null && username.trim().isNotEmpty)
          'username': username.trim(),
        if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
          'avatar_url': avatarUrl.trim(),
      };

      emit(
        AccountsLoaded(
          accounts: current.accounts,
          totalBalance: current.totalBalance,
          profile: nextProfile,
        ),
      );
    }

    try {
      await _repository.updateProfile(
        fullName: fullName,
        username: username,
        avatarUrl: avatarUrl,
      );
      await loadAccounts();
    } catch (error) {
      emit(AccountsError(error.toString()));
      if (current != null) emit(current);
    }
  }
}
