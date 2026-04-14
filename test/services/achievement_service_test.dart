import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/services/achievement_service.dart';

void main() {
  group('AchievementService singleton', () {
    test('returns the same instance', () {
      final a = AchievementService();
      final b = AchievementService();
      expect(identical(a, b), isTrue);
    });
  });

  group('AchievementService._parseDecade', () {
    final service = AchievementService();

    test('parses 4-digit year', () {
      expect(service.parseDecadeForTest('1967'), 1960);
      expect(service.parseDecadeForTest('1985'), 1980);
      expect(service.parseDecadeForTest('2003'), 2000);
    });

    test('parses year range — uses first year', () {
      expect(service.parseDecadeForTest('1965-1970'), 1960);
      expect(service.parseDecadeForTest('1978-1982'), 1970);
    });

    test('parses year with prefix text', () {
      expect(service.parseDecadeForTest('circa 1960'), 1960);
      expect(service.parseDecadeForTest('Prodotta dal 1955 al 1965'), 1950);
    });

    test('returns null for unparseable string', () {
      expect(service.parseDecadeForTest('anni \'60'), isNull);
      expect(service.parseDecadeForTest('sconosciuto'), isNull);
      expect(service.parseDecadeForTest(''), isNull);
    });

    test('returns null for years outside regex range', () {
      // Regex matches 1800-2099 range (1[89]\d{2}|20\d{2})
      expect(service.parseDecadeForTest('1750'), isNull);
      expect(service.parseDecadeForTest('2150'), isNull);
    });

    test('decade boundary — 1970 maps to 1970', () {
      expect(service.parseDecadeForTest('1970'), 1970);
    });

    test('decade boundary — 1979 maps to 1970', () {
      expect(service.parseDecadeForTest('1979'), 1970);
    });

    test('decade boundary — 1980 maps to 1980', () {
      expect(service.parseDecadeForTest('1980'), 1980);
    });
  });
}
