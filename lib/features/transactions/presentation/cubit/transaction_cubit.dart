import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/transaction_repository_impl.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  TransactionLoaded(this.transactions);

  final List<Map<String, dynamic>> transactions;
}

class TransactionError extends TransactionState {
  TransactionError(this.message);

  final String message;
}

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit(this._repository) : super(TransactionInitial());

  final TransactionRepository _repository;
  bool _mutationInProgress = false;

  void clear() {
    emit(TransactionInitial());
  }

  Future<void> loadTransactions() async {
    final current = state is TransactionLoaded
        ? state as TransactionLoaded
        : null;
    if (current == null) {
      emit(TransactionLoading());
    }

    try {
      final transactions = await _repository.getTransactions();
      emit(TransactionLoaded(transactions));
    } catch (error) {
      emit(TransactionError(error.toString()));
      if (current != null) emit(current);
    }
  }

  Future<void> createTransaction({
    required String accountId,
    required String merchantName,
    required double amount,
    required String type,
    String? categoryId,
  }) async {
    if (_mutationInProgress) return;
    _mutationInProgress = true;
    try {
      await _repository.addTransaction(
        accountId: accountId,
        merchantName: merchantName,
        amount: amount,
        type: type,
        categoryId: categoryId,
      );
      await loadTransactions();
    } catch (error) {
      emit(TransactionError(error.toString()));
    } finally {
      _mutationInProgress = false;
    }
  }

  Future<void> createTransactions({
    required String accountId,
    required List<
      ({String merchantName, double amount, String type, String? categoryId})
    >
    transactions,
  }) async {
    if (_mutationInProgress) return;
    _mutationInProgress = true;
    try {
      await _repository.addTransactions(
        accountId: accountId,
        transactions: transactions,
      );

      await loadTransactions();
    } catch (error) {
      emit(TransactionError(error.toString()));
    } finally {
      _mutationInProgress = false;
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    if (_mutationInProgress) return false;
    _mutationInProgress = true;
    final current = state is TransactionLoaded
        ? state as TransactionLoaded
        : null;
    try {
      await _repository.deleteTransaction(transactionId);
      await loadTransactions();
      return true;
    } catch (error) {
      emit(TransactionError(error.toString()));
      if (current != null) emit(current);
      return false;
    } finally {
      _mutationInProgress = false;
    }
  }
}
