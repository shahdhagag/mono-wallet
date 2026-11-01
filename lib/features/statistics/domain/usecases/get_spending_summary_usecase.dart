import '../entities/spending_summary.dart';
import '../repositories/statistics_repository.dart';

class GetSpendingSummaryUseCase {
  const GetSpendingSummaryUseCase(this.repository);

  final StatisticsRepository repository;

  Future<List<SpendingSummary>> call() {
    return repository.getSpendingSummary();
  }
}