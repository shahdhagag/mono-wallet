import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../data/services/gemini_expense_parser.dart';

class VoiceExpenseInput extends StatefulWidget {
  const VoiceExpenseInput({required this.onExpensesParsed, super.key});

  final Future<void> Function(List<VoiceExpense> expenses) onExpensesParsed;

  @override
  State<VoiceExpenseInput> createState() => _VoiceExpenseInputState();
}

class _VoiceExpenseInputState extends State<VoiceExpenseInput> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final GeminiExpenseParser _parser = GeminiExpenseParser();
  bool _isListening = false;
  bool _isParsing = false;
  bool _stopHandled = false;
  bool _retriedAfterNoMatch = false;
  List<String?> _localeCandidates = const [];
  int _localeIndex = 0;
  String _transcript = '';

  @override
  void dispose() {
    _parser.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      await _handleStop();
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && _isListening) {
          _handleStop();
        }
      },
      onError: (error) {
        final details = error.errorMsg.trim();
        final noMatch =
            details.contains('error_no_match') ||
            details.contains('error_speech_timeout');

        if (noMatch) {
          _stopHandled = true;
          if (mounted) setState(() => _isListening = false);
          if (_transcript.trim().isNotEmpty) {
            _parseTranscript();
          } else if (!_retriedAfterNoMatch &&
              _localeIndex + 1 < _localeCandidates.length) {
            _retriedAfterNoMatch = true;
            _localeIndex += 1;
            _retryWithLocale(_localeCandidates[_localeIndex]);
          } else if (mounted) {
            _showMessage(
              'I could not hear any words. Speak closer to the microphone and try again.',
            );
          }
          return;
        }

        if (mounted) {
          setState(() => _isListening = false);
          _showMessage(
            details.contains('error_unknown (300)')
                ? 'The device speech service could not start. Check that Google voice recognition is enabled, then try again.'
                : details.isEmpty
                ? 'Speech recognition stopped. Check microphone permission and try again.'
                : 'Speech recognition error: $details',
          );
        }
      },
    );
    if (!available) {
      _showMessage('Speech recognition is unavailable on this device.');
      return;
    }

    final locales = await _speech.locales();
    _localeCandidates = _buildLocaleCandidates(locales);
    _localeIndex = 0;
    _retriedAfterNoMatch = false;

    setState(() {
      _transcript = '';
      _isListening = true;
      _stopHandled = false;
    });
    await _startListeningWithLocale(_localeCandidates.first);
  }

  Future<void> _startListeningWithLocale(String? localeId) async {
    if (!mounted) return;
    setState(() {
      _isListening = true;
      _stopHandled = false;
    });
    await _speech.listen(
      onResult: (result) {
        if (mounted && result.recognizedWords.trim().isNotEmpty) {
          setState(() => _transcript = result.recognizedWords);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: localeId,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        partialResults: true,
      ),
    );
  }

  Future<void> _retryWithLocale(String? localeId) async {
    await _speech.stop();
    if (!mounted) return;
    await _startListeningWithLocale(localeId);
  }

  List<String?> _buildLocaleCandidates(List<stt.LocaleName> locales) {
    final available = locales.map((locale) => locale.localeId).toList();
    final candidates = <String?>[];
    for (final preferred in ['ar-EG', 'en-US', 'ar', 'en']) {
      final matches = available.where(
        (localeId) => localeId.toLowerCase() == preferred.toLowerCase(),
      );
      if (matches.isNotEmpty && !candidates.contains(matches.first)) {
        candidates.add(matches.first);
      }
    }
    if (candidates.isEmpty) {
      candidates.add(available.isNotEmpty ? available.first : null);
    }
    return candidates;
  }

  Future<void> _handleStop() async {
    if (_stopHandled || !_isListening) return;
    _stopHandled = true;
    if (mounted) setState(() => _isListening = false);
    await _parseTranscript();
  }

  Future<void> _parseTranscript() async {
    final transcript = _transcript.trim();
    if (transcript.isEmpty) return;

    setState(() => _isParsing = true);
    try {
      final expenses = await _parser.parse(transcript);
      if (!mounted) return;
      if (expenses.isEmpty) {
        _showMessage('No expense was found in that recording.');
      } else {
        await widget.onExpensesParsed(expenses);
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isParsing = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            _isListening ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
            color: const Color(0xFF2E8C85),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isParsing
                      ? 'Understanding your expenses...'
                      : _isListening
                      ? 'Listening...'
                      : 'Log by voice',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E2A39),
                  ),
                ),
                if (_transcript.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _transcript,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: _isListening ? 'Stop recording' : 'Start recording',
            onPressed: _isParsing ? null : _toggleListening,
            icon: Icon(
              _isListening ? Icons.stop_circle_rounded : Icons.mic_rounded,
              color: const Color(0xFF2E8C85),
            ),
          ),
        ],
      ),
    );
  }
}
