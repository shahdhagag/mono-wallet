import '../domain/entities/transaction.dart';

class HomeRemoteDataSource {
  const HomeRemoteDataSource();

  Future<List<TransactionItem>> getRecentTransactions() async {
    return const <TransactionItem>[
      TransactionItem(
        title: 'Coffee Shop',
        amount: '- 24.00 EGP',
        subtitle: 'Today · Food & Drinks',
      ),
      TransactionItem(
        title: 'Salary',
        amount: '+ 12,500.00 EGP',
        subtitle: 'Yesterday · Income',
      ),
      TransactionItem(
        title: 'Internet Bill',
        amount: '- 450.00 EGP',
        subtitle: '2 days ago · Utilities',
      ),
    ];
  }
}