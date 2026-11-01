import '../domain/entities/wallet_account.dart';

class WalletRemoteDataSource {
  const WalletRemoteDataSource();

  Future<List<WalletAccount>> getAccounts() async {
    return const <WalletAccount>[
      WalletAccount(name: 'Main wallet', balance: 84250),
      WalletAccount(name: 'Savings', balance: 27500),
    ];
  }
}