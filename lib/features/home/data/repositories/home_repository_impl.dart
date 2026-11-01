import '../../domain/entities/transaction.dart';
import '../../domain/repositories/home_repository.dart';
import '../home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this.remoteDataSource);

  final HomeRemoteDataSource remoteDataSource;

  @override
  Future<List<TransactionItem>> getRecentTransactions() {
    return remoteDataSource.getRecentTransactions();
  }
}