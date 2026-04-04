import 'package:flutter_test/flutter_test.dart';

/// Tests URL extraction logic used in home_screen.dart _pasteLink()
/// Bug: links from Subito.it app were rejected because the clipboard
/// contained extra text before/after the URL.
void main() {
  String? extractUrl(String text) {
    final urlMatch = RegExp(r'https?://[^\s<>"]+').firstMatch(text.trim());
    return urlMatch?.group(0);
  }

  group('URL extraction from clipboard', () {
    test('plain HTTPS URL', () {
      expect(
        extractUrl('https://www.subito.it/auto/fiat-500-roma-123456.htm'),
        equals('https://www.subito.it/auto/fiat-500-roma-123456.htm'),
      );
    });

    test('plain HTTP URL', () {
      expect(
        extractUrl('http://www.autoscout24.it/annunci/auto-123'),
        equals('http://www.autoscout24.it/annunci/auto-123'),
      );
    });

    test('URL with text before (Subito app share format)', () {
      expect(
        extractUrl('Guarda questo annuncio su Subito: https://www.subito.it/auto/500-l-storica-asi-originale-non-restaurata-torino-639987820.htm'),
        equals('https://www.subito.it/auto/500-l-storica-asi-originale-non-restaurata-torino-639987820.htm'),
      );
    });

    test('URL with text before and after', () {
      expect(
        extractUrl('Ho trovato questa auto https://www.autoscout24.it/annunci/auto-123 che ne pensi?'),
        equals('https://www.autoscout24.it/annunci/auto-123'),
      );
    });

    test('URL with leading/trailing whitespace', () {
      expect(
        extractUrl('  https://www.subito.it/auto/test-123.htm  '),
        equals('https://www.subito.it/auto/test-123.htm'),
      );
    });

    test('URL with newlines (mobile copy)', () {
      expect(
        extractUrl('\nhttps://www.subito.it/auto/test-123.htm\n'),
        equals('https://www.subito.it/auto/test-123.htm'),
      );
    });

    test('URL with query parameters', () {
      expect(
        extractUrl('https://www.autoscout24.it/annunci/auto?id=123&ref=share'),
        equals('https://www.autoscout24.it/annunci/auto?id=123&ref=share'),
      );
    });

    test('no URL in text returns null', () {
      expect(extractUrl('Ciao, come stai?'), isNull);
    });

    test('empty string returns null', () {
      expect(extractUrl(''), isNull);
    });

    test('just whitespace returns null', () {
      expect(extractUrl('   '), isNull);
    });

    test('URL-like text without protocol returns null', () {
      expect(extractUrl('www.subito.it/auto/test'), isNull);
    });

    test('AutoScout24 URL', () {
      expect(
        extractUrl('https://www.autoscout24.it/lst/alfa-romeo/giulia?sort=standard'),
        equals('https://www.autoscout24.it/lst/alfa-romeo/giulia?sort=standard'),
      );
    });

    test('AutoUncle URL', () {
      expect(
        extractUrl('https://www.autouncle.it/it/auto-usate/alfa-romeo/giulia'),
        equals('https://www.autouncle.it/it/auto-usate/alfa-romeo/giulia'),
      );
    });

    test('Subito app share with emoji', () {
      expect(
        extractUrl('🚗 Ho trovato questa! https://www.subito.it/auto/fiat-124-spider-milano-999999.htm'),
        equals('https://www.subito.it/auto/fiat-124-spider-milano-999999.htm'),
      );
    });
  });
}
