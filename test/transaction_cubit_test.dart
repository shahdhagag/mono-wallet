import 'package:flutter_test/flutter_test.dart';

import 'package:mono_wallet/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:mono_wallet/features/transactions/presentation/cubit/transaction_cubit.dart';

class FakeTransactionRepository implements TransactionRepository {
  int addTransactionsCalls = 0;
  Object? addTransactionsError;
  Object? deleteError;

  @override
  Future<List<Map<String, dynamic>>> getTransactions() async {
    return [
      {
        'id': 'txn_1',
        'merchant_name': 'Coffee House',
        'amount': 14.75,
        'type': 'expense',
      },
    ];
  }

  @override
  Future<void> addTransaction({
    required String accountId,
    required String merchantName,
    required double amount,
    required String type,
    String? categoryId,
  }) async {}

  @override
  Future<void> addTransactions({
    required String accountId,
    required List<
      ({String merchantName, double amount, String type, String? categoryId})
    >
    transactions,
  }) async {
    addTransactionsCalls += 1;
    if (addTransactionsError != null) {
      throw addTransactionsError!;
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    if (deleteError != null) throw deleteError!;
  }
}

void main() {
  test('TransactionCubit loads transactions from the repository', () async {
    final cubit = TransactionCubit(FakeTransactionRepository());

    await cubit.loadTransactions();

    expect(cubit.state, isA<TransactionLoaded>());
    final state = cubit.state as TransactionLoaded;
    expect(state.transactions, isNotEmpty);
    expect(state.transactions.first['merchant_name'], 'Coffee House');
  });

  test('TransactionCubit reports a successful deletion', () async {
    final cubit = TransactionCubit(FakeTransactionRepository());

    final deleted = await cubit.deleteTransaction('txn_1');

    expect(deleted, isTrue);
    expect(cubit.state, isA<TransactionLoaded>());
  });

  test('TransactionRepository normalizes invalid fallback category ids', () {
    const validUuid = '01234567-89ab-41cd-8123-456789abcdef';

    expect(
      TransactionRepositoryImpl.normalizeCategoryId('fallback_food'),
      isNull,
    );
    expect(
      TransactionRepositoryImpl.normalizeCategoryId(validUuid),
      equals(validUuid),
    );
  });

  test('TransactionRepository rejects invalid transaction input', () {
    expect(
      () => TransactionRepositoryImpl.validateTransactionInput(
        merchantName: 'Groceries',
        amount: 0,
        type: 'expense',
      ),
      throwsException,
    );
    expect(
      () => TransactionRepositoryImpl.validateTransactionInput(
        merchantName: 'Groceries',
        amount: 10,
        type: 'transfer',
      ),
      throwsException,
    );
    expect(
      () => TransactionRepositoryImpl.validateTransactionInput(
        merchantName: 'Groceries',
        amount: double.nan,
        type: 'expense',
      ),
      throwsException,
    );
  });

  test('TransactionCubit submits voice transactions as one batch', () async {
    final repository = FakeTransactionRepository();
    final cubit = TransactionCubit(repository);

    await cubit.createTransactions(
      accountId: 'account-1',
      transactions: [
        (
          merchantName: 'Groceries',
          amount: 150,
          type: 'expense',
          categoryId: null,
        ),
        (
          merchantName: 'Transport',
          amount: 80,
          type: 'expense',
          categoryId: null,
        ),
      ],
    );

    expect(repository.addTransactionsCalls, 1);
    expect(cubit.state, isA<TransactionLoaded>());
  });

  test('TransactionCubit exposes a batch database failure', () async {
    final repository = FakeTransactionRepository()
      ..addTransactionsError = Exception('database failure');
    final cubit = TransactionCubit(repository);

    await cubit.createTransactions(
      accountId: 'account-1',
      transactions: [
        (
          merchantName: 'Groceries',
          amount: 150,
          type: 'expense',
          categoryId: null,
        ),
      ],
    );

    expect(cubit.state, isA<TransactionError>());
  });

  test(
    'TransactionCubit reports a missing transaction during deletion',
    () async {
      final repository = FakeTransactionRepository()
        ..deleteError = Exception('Transaction could not be found.');
      final cubit = TransactionCubit(repository);

      final deleted = await cubit.deleteTransaction('missing-transaction');

      expect(deleted, isFalse);
      expect(cubit.state, isA<TransactionError>());
    },
  );
}
