import '../entities/spending_summary.dart';

abstract class StatisticsRepository {
  Future<List<SpendingSummary>> getSpendingSummary();
}