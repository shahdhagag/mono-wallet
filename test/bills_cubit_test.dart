import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:mono_wallet/features/bills/data/repositories/bill_repository_impl.dart';
import 'package:mono_wallet/features/bills/presentation/cubit/bills_cubit.dart';

class _FakeBillRepository implements BillRepository {
  _FakeBillRepository({this.blockPayment = false, this.paymentError});

  final bool blockPayment;
  final Object? paymentError;
  final paymentStarted = Completer<void>();
  final releasePayment = Completer<void>();
  int paymentCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> getBills() async => const [];

  @override
  Future<void> payBill({
    required String billId,
    required String accountId,
    required double amount,
    required String billName,
  }) async {
    paymentCalls += 1;
    if (paymentError != null) throw paymentError!;
    if (!paymentStarted.isCompleted) paymentStarted.complete();
    if (blockPayment) await releasePayment.future;
  }
}

void main() {
  test(
    'BillsCubit emits payment success after the repository succeeds',
    () async {
      final cubit = BillsCubit(_FakeBillRepository());

      await cubit.payBill(
        billId: 'bill-1',
        accountId: 'account-1',
        amount: 10,
        billName: 'Internet',
      );

      expect(cubit.state, isA<BillsPaymentSuccess>());
    },
  );

  test(
    'BillsCubit ignores a duplicate payment while one is in progress',
    () async {
      final repository = _FakeBillRepository(blockPayment: true);
      final cubit = BillsCubit(repository);

      final firstPayment = cubit.payBill(
        billId: 'bill-1',
        accountId: 'account-1',
        amount: 10,
        billName: 'Internet',
      );
      await repository.paymentStarted.future;

      final secondPayment = cubit.payBill(
        billId: 'bill-1',
        accountId: 'account-1',
        amount: 10,
        billName: 'Internet',
      );

      await secondPayment;
      expect(repository.paymentCalls, 1);

      repository.releasePayment.complete();
      await firstPayment;
    },
  );

  test('BillsCubit reports a missing bill or database failure', () async {
    final cubit = BillsCubit(
      _FakeBillRepository(paymentError: Exception('Bill could not be found.')),
    );

    await cubit.payBill(
      billId: 'missing-bill',
      accountId: 'account-1',
      amount: 10,
      billName: 'Internet',
    );

    expect(cubit.state, isA<BillsError>());
    expect((cubit.state as BillsError).message, contains('could not be found'));
  });
}
