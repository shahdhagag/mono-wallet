import '../../domain/entities/transaction.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.transactions);

  final List<TransactionItem> transactions;
}