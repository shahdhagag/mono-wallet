import '../entities/wallet_account.dart';

abstract class WalletRepository {
  Future<List<WalletAccount>> getAccounts();
}