import '../domain/entities/spending_summary.dart';

class StatisticsRemoteDataSource {
  const StatisticsRemoteDataSource();

  Future<List<SpendingSummary>> getSpendingSummary() async {
    return const <SpendingSummary>[
      SpendingSummary(label: 'Food', value: 38),
      SpendingSummary(label: 'Transport', value: 22),
      SpendingSummary(label: 'Bills', value: 17),
      SpendingSummary(label: 'Others', value: 23),
    ];
  }
}