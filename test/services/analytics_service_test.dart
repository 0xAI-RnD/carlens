import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/services/analytics_service.dart';

void main() {
  // Note: AnalyticsService singleton cannot be instantiated in unit tests
  // because FirebaseAnalytics.instance requires Firebase.initializeApp().
  // _truncate is tested via its static @visibleForTesting wrapper.

  group('AnalyticsService._truncate', () {
    test('returns string unchanged when under 100 chars', () {
      expect(AnalyticsService.truncateForTest('Ferrari'), 'Ferrari');
    });

    test('returns string unchanged at exactly 100 chars', () {
      final s = 'A' * 100;
      expect(AnalyticsService.truncateForTest(s).length, 100);
    });

    test('truncates string longer than 100 chars to exactly 100', () {
      final s = 'B' * 150;
      final result = AnalyticsService.truncateForTest(s);
      expect(result.length, 100);
      expect(result, 'B' * 100);
    });

    test('returns empty string unchanged', () {
      expect(AnalyticsService.truncateForTest(''), '');
    });

    test('truncates at 101 chars', () {
      final s = 'C' * 101;
      expect(AnalyticsService.truncateForTest(s).length, 100);
    });

    test('preserves content up to 100 chars exactly', () {
      final prefix = 'X' * 100;
      final s = prefix + 'OVERFLOW';
      expect(AnalyticsService.truncateForTest(s), prefix);
    });
  });
}
