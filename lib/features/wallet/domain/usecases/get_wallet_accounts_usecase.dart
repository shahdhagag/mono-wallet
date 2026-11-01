import '../entities/wallet_account.dart';
import '../repositories/wallet_repository.dart';

class GetWalletAccountsUseCase {
  const GetWalletAccountsUseCase(this.repository);

  final WalletRepository repository;

  Future<List<WalletAccount>> call() {
    return repository.getAccounts();
  }
}