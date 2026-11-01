import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:mono_wallet/features/transactions/data/services/gemini_expense_parser.dart';

class _FakeGeminiClient extends http.BaseClient {
  _FakeGeminiClient(this.body);

  final String body;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      200,
      request: request,
    );
  }
}

void main() {
  test('normalizes Arabic-Indic and Persian digits', () {
    expect(GeminiExpenseParser.normalizeDigits('١٥٠٫٥٠ و ۵۰'), '150.50 و 50');
  });

  test('parses multiple typed expenses from Gemini JSON', () async {
    final parser = GeminiExpenseParser(
      client: _FakeGeminiClient(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text': jsonEncode({
                      'expenses': [
                        {
                          'item': 'Groceries',
                          'amount': 150,
                          'category': 'Food',
                          'type': 'expense',
                        },
                        {
                          'item': 'Salary',
                          'amount': 5000,
                          'category': 'Other',
                          'type': 'income',
                        },
                      ],
                    }),
                  },
                ],
              },
            },
          ],
        }),
      ),
      endpoint: Uri.parse('https://example.test/parse-expense'),
      accessTokenProvider: () async => 'test-token',
    );

    final result = await parser.parse('دفعت ١٥٠ جنيه ومرتبي ٥٠٠٠');

    expect(result, hasLength(2));
    expect(result[0].amount, 150);
    expect(result[0].type, 'expense');
    expect(result[1].type, 'income');
    parser.dispose();
  });

  test('rejects a parsed item without an explicit type', () async {
    final parser = GeminiExpenseParser(
      client: _FakeGeminiClient(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text':
                        '{"expenses":[{"item":"Shopping","amount":100,"category":"Shopping"}]}',
                  },
                ],
              },
            },
          ],
        }),
      ),
      endpoint: Uri.parse('https://example.test/parse-expense'),
      accessTokenProvider: () async => 'test-token',
    );

    expect(() => parser.parse('I spent 100'), throwsA(isA<Exception>()));
    parser.dispose();
  });

  test('parses the response returned by the Edge Function', () async {
    final parser = GeminiExpenseParser(
      client: _FakeGeminiClient(
        '{"expenses":[{"item":"Taxi","amount":80,"category":"Transport","type":"expense"}]}',
      ),
      endpoint: Uri.parse('https://example.test/parse-expense'),
      accessTokenProvider: () async => 'test-token',
    );

    final result = await parser.parse('taxi 80');

    expect(result.single.item, 'Taxi');
    expect(result.single.amount, 80);
    parser.dispose();
  });
}
