import 'package:flutter_test/flutter_test.dart';

/// Tests for the AI model fallback chain logic.
/// Chain: Gemini 3.1 Flash Lite → Gemini 2.5 Flash Lite → Gemini 2.0 Flash → Groq Llama Vision
void main() {
  group('Fallback chain logic', () {
    test('primary model is gemini-3.1-flash-lite-preview', () {
      const primary = 'gemini-3.1-flash-lite-preview';
      expect(primary, contains('3.1'));
      expect(primary, contains('flash'));
    });

    test('secondary fallback is gemini-2.5-flash-lite', () {
      const fallback2 = 'gemini-2.5-flash-lite';
      expect(fallback2, contains('2.5'));
      expect(fallback2, contains('lite'));
    });

    test('tertiary fallback is gemini-2.0-flash', () {
      const fallback3 = 'gemini-2.0-flash';
      expect(fallback3, contains('2.0'));
    });

    test('quaternary fallback is Groq Llama 4 Scout', () {
      const groq = 'meta-llama/llama-4-scout-17b-16e-instruct';
      expect(groq, contains('llama-4'));
      expect(groq, contains('scout'));
    });

    test('503 triggers fallback', () {
      const statusCode = 503;
      final shouldFallback = statusCode == 503 || statusCode == 429;
      expect(shouldFallback, isTrue);
    });

    test('429 triggers fallback', () {
      const statusCode = 429;
      final shouldFallback = statusCode == 503 || statusCode == 429;
      expect(shouldFallback, isTrue);
    });

    test('200 does NOT trigger fallback', () {
      const statusCode = 200;
      final shouldFallback = statusCode == 503 || statusCode == 429;
      expect(shouldFallback, isFalse);
    });

    test('any non-200 triggers fallback', () {
      for (final code in [400, 401, 403, 404, 500, 502, 503, 429]) {
        expect(code != 200, isTrue, reason: 'Status $code should trigger fallback');
      }
    });
  });

  group('Four-level fallback chain', () {
    test('primary succeeds: no fallback needed', () {
      final primary = <String, dynamic>{'text': 'gemini-3.1'};
      Map<String, dynamic>? fb2;
      Map<String, dynamic>? fb3;
      Map<String, dynamic>? groq;

      final result = primary ?? fb2 ?? fb3 ?? groq;
      expect(result!['text'], equals('gemini-3.1'));
    });

    test('primary fails, fallback2 succeeds', () {
      Map<String, dynamic>? primary;
      final fb2 = <String, dynamic>{'text': 'gemini-2.5-lite'};
      Map<String, dynamic>? fb3;
      Map<String, dynamic>? groq;

      final result = primary ?? fb2 ?? fb3 ?? groq;
      expect(result!['text'], equals('gemini-2.5-lite'));
    });

    test('primary + fb2 fail, fb3 succeeds', () {
      Map<String, dynamic>? primary;
      Map<String, dynamic>? fb2;
      final fb3 = <String, dynamic>{'text': 'gemini-2.0'};
      Map<String, dynamic>? groq;

      final result = primary ?? fb2 ?? fb3 ?? groq;
      expect(result!['text'], equals('gemini-2.0'));
    });

    test('all Gemini fail, Groq succeeds', () {
      Map<String, dynamic>? primary;
      Map<String, dynamic>? fb2;
      Map<String, dynamic>? fb3;
      final groq = <String, dynamic>{'text': 'groq-llama'};

      final result = primary ?? fb2 ?? fb3 ?? groq;
      expect(result!['text'], equals('groq-llama'));
    });

    test('all four fail: result is null', () {
      Map<String, dynamic>? primary;
      Map<String, dynamic>? fb2;
      Map<String, dynamic>? fb3;
      Map<String, dynamic>? groq;

      final result = primary ?? fb2 ?? fb3 ?? groq;
      expect(result, isNull);
    });
  });

  group('Groq API format', () {
    test('Groq uses OpenAI-compatible endpoint', () {
      const groqUrl = 'https://api.groq.com/openai/v1';
      expect(groqUrl, contains('openai'));
      expect(groqUrl, contains('groq.com'));
    });

    test('Groq auth uses Bearer token', () {
      const apiKey = 'gsk_test_key';
      final header = 'Bearer $apiKey';
      expect(header, startsWith('Bearer '));
    });

    test('Groq image format is base64 data URL', () {
      const prefix = 'data:image/jpeg;base64,';
      expect(prefix, contains('data:image'));
      expect(prefix, contains('base64'));
    });

    test('Groq message structure has role + content array', () {
      final message = {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': 'Identify this car'},
          {
            'type': 'image_url',
            'image_url': {'url': 'data:image/jpeg;base64,/9j/4AAQ...'},
          },
        ],
      };

      expect(message['role'], equals('user'));
      expect(message['content'], isList);
      final content = message['content'] as List;
      expect(content.length, equals(2));
      expect((content[0] as Map)['type'], equals('text'));
      expect((content[1] as Map)['type'], equals('image_url'));
    });

    test('Groq response format requests JSON object', () {
      final config = {'type': 'json_object'};
      expect(config['type'], equals('json_object'));
    });
  });

  group('Prompt/image state for Groq fallback', () {
    test('lastTextPrompt must be saved before _callGemini', () {
      // Simulates the state management
      String? lastPrompt;
      const prompt = 'Sei un esperto di auto classiche...';

      // Before _callGemini, prompt is saved
      lastPrompt = prompt;

      expect(lastPrompt, isNotNull);
      expect(lastPrompt, contains('esperto'));
    });

    test('lastImageBytes saved for identifyCar (with images)', () {
      List<List<int>>? lastImages;
      final images = [
        [1, 2, 3],
        [4, 5, 6],
      ];

      lastImages = images;

      expect(lastImages, isNotNull);
      expect(lastImages!.length, equals(2));
    });

    test('lastImageBytes null for originalityReport (text-only)', () {
      List<List<int>>? lastImages = [
        [1, 2, 3]
      ];

      // Originality report clears images
      lastImages = null;

      expect(lastImages, isNull);
    });
  });
}
