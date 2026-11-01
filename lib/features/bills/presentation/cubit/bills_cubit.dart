import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/bill_repository_impl.dart';

abstract class BillsState {}

class BillsInitial extends BillsState {}

class BillsLoading extends BillsState {}

class BillsLoaded extends BillsState {
  BillsLoaded(this.bills);

  final List<Map<String, dynamic>> bills;
}

class BillsError extends BillsState {
  BillsError(this.message);

  final String message;
}

class BillsPaymentLoading extends BillsState {}

class BillsPaymentSuccess extends BillsState {}

class BillsCubit extends Cubit<BillsState> {
  BillsCubit(this._repository) : super(BillsInitial());

  final BillRepository _repository;
  bool _paymentInProgress = false;

  void clear() {
    emit(BillsInitial());
  }

  Future<void> loadBills() async {
    emit(BillsLoading());

    try {
      final bills = await _repository.getBills();
      emit(BillsLoaded(bills));
    } catch (error) {
      emit(BillsError(error.toString()));
    }
  }

  Future<void> payBill({
    required String billId,
    required String accountId,
    required double amount,
    required String billName,
  }) async {
    if (_paymentInProgress) return;
    _paymentInProgress = true;
    emit(BillsPaymentLoading());

    try {
      await _repository.payBill(
        billId: billId,
        accountId: accountId,
        amount: amount,
        billName: billName,
      );
      await loadBills();
      emit(BillsPaymentSuccess());
    } catch (error) {
      emit(BillsError(error.toString()));
    } finally {
      _paymentInProgress = false;
    }
  }
}
