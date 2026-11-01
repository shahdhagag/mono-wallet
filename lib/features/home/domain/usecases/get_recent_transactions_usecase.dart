import '../entities/transaction.dart';
import '../repositories/home_repository.dart';

class GetRecentTransactionsUseCase {
  const GetRecentTransactionsUseCase(this.repository);

  final HomeRepository repository;

  Future<List<TransactionItem>> call() {
    return repository.getRecentTransactions();
  }
}