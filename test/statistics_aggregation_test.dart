import 'package:flutter_test/flutter_test.dart';

import 'package:mono_wallet/features/statistics/domain/entities/spending_summary.dart';
import 'package:mono_wallet/features/statistics/presentation/views/statistics_view.dart';

void main() {
  test('summarizeTransactionsByCategory groups expense totals by label', () {
    final transactions = <Map<String, dynamic>>[
      {'type': 'expense', 'amount': 25.0, 'merchant_name': 'Spotify'},
      {'type': 'expense', 'amount': 15.0, 'merchant_name': 'Spotify'},
      {'type': 'expense', 'amount': 40.0, 'merchant_name': 'Housing'},
      {'type': 'income', 'amount': 200.0, 'merchant_name': 'Paycheck'},
    ];

    final result = summarizeTransactionsByCategory(transactions, 'expense');

    expect(result, isA<List<SpendingSummary>>());
    expect(result.length, 2);
    expect(result.first.label, 'Spotify');
    expect(result.first.value, 40.0);
    expect(result.last.label, 'Housing');
    expect(result.last.value, 40.0);
  });

  test('summarizeTransactionsByCategory prefers the related category name', () {
    final result = summarizeTransactionsByCategory([
      {
        'type': 'expense',
        'amount': 25.0,
        'merchant_name': 'Supermarket',
        'categories': {'name': 'Food'},
      },
    ], 'expense');

    expect(result.single.label, 'Food');
  });
}
