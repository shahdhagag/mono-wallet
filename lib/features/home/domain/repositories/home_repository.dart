import '../entities/transaction.dart';

abstract class HomeRepository {
  Future<List<TransactionItem>> getRecentTransactions();
}