import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class VoiceExpense {
  const VoiceExpense({
    required this.item,
    required this.amount,
    required this.category,
    required this.type,
  });

  final String item;
  final double amount;
  final String category;
  final String type;

  VoiceExpense copyWith({
    String? item,
    double? amount,
    String? category,
    String? type,
  }) {
    return VoiceExpense(
      item: item ?? this.item,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
    );
  }
}

class GeminiExpenseParser {
  GeminiExpenseParser({
    http.Client? client,
    Uri? endpoint,
    Future<String?> Function()? accessTokenProvider,
  }) : _client = client ?? http.Client(),
       _endpoint =
           endpoint ??
           Uri.parse(
             'https://kjxffcmjpiaapqihnesz.supabase.co/functions/v1/parse-expense',
           ),
       _accessTokenProvider =
           accessTokenProvider ??
           (() async =>
               Supabase.instance.client.auth.currentSession?.accessToken);

  final http.Client _client;
  final Uri _endpoint;
  final Future<String?> Function() _accessTokenProvider;

  static String normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final codeUnit in input.codeUnits) {
      if (codeUnit >= 0x0660 && codeUnit <= 0x0669) {
        buffer.writeCharCode(0x30 + codeUnit - 0x0660);
      } else if (codeUnit >= 0x06F0 && codeUnit <= 0x06F9) {
        buffer.writeCharCode(0x30 + codeUnit - 0x06F0);
      } else if (codeUnit == 0x066B) {
        buffer.write('.');
      } else if (codeUnit == 0x066C) {
        continue;
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  Future<List<VoiceExpense>> parse(String transcript) async {
    final normalizedTranscript = normalizeDigits(transcript.trim());
    if (normalizedTranscript.isEmpty) {
      throw Exception('Please record a voice note before parsing it.');
    }

    final accessToken = await _accessTokenProvider();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Please sign in before using voice expense parsing.');
    }

    late final http.Response response;
    try {
      response = await _client
          .post(
            _endpoint,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'transcript': normalizedTranscript}),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw Exception(
        'Could not reach Gemini. Check your internet connection and try again.',
      );
    }

    if (response.statusCode == 429) {
      throw Exception(
        'Voice parsing is busy right now. Wait a moment and try again.',
      );
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Your session expired. Sign in again and retry.');
    }
    if (response.statusCode != 200) {
      throw Exception(
        'Voice parsing failed (${response.statusCode}). Try again.',
      );
    }

    late final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Gemini returned an unreadable response. Try again.');
    }

    final proxyExpenses = data['expenses'];
    if (proxyExpenses is List) {
      return _parseExpenses(proxyExpenses);
    }

    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      final feedback = data['promptFeedback'];
      final blockReason = feedback is Map ? feedback['blockReason'] : null;
      throw Exception(
        blockReason == null
            ? 'Gemini returned no result. Try again.'
            : 'Gemini blocked the request ($blockReason). Try rephrasing.',
      );
    }

    late final String text;
    try {
      final candidate = candidates.first as Map;
      final content = candidate['content'] as Map;
      final parts = content['parts'] as List;
      text = (parts.first as Map)['text'] as String;
    } catch (_) {
      throw Exception('Gemini returned an unexpected response. Try again.');
    }

    final jsonText = _extractJson(text);
    if (jsonText == null) {
      throw Exception('Could not understand Gemini\'s response. Try again.');
    }

    late final Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(jsonText) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
        'Could not parse the expenses. Try speaking more clearly.',
      );
    }
    final expenses = parsed['expenses'];
    if (expenses is! List) return [];
    return _parseExpenses(expenses);
  }

  List<VoiceExpense> _parseExpenses(List<dynamic> expenses) {
    return expenses
        .whereType<Map>()
        .map((expense) {
          final item = (expense['item'] as String? ?? '').trim();
          final amount = (expense['amount'] as num?)?.toDouble() ?? 0;
          final category = (expense['category'] as String? ?? 'Other').trim();
          final type = (expense['type'] as String?)?.trim().toLowerCase();
          if (type != 'income' && type != 'expense') {
            throw Exception(
              'I could not determine whether one item was income or expense. '
              'Please rephrase it or add it manually.',
            );
          }
          return VoiceExpense(
            item: item,
            amount: amount,
            category: category,
            type: type!,
          );
        })
        .where(
          (expense) =>
              expense.item.isNotEmpty &&
              expense.amount.isFinite &&
              expense.amount > 0,
        )
        .toList();
  }

  String? _extractJson(String raw) {
    final text = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1 || end < start) return null;
    return text.substring(start, end + 1);
  }

  void dispose() => _client.close();
}
