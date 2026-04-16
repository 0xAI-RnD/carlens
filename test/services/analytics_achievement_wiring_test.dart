import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression test for Phase 03 gap (03-VERIFICATION.md):
/// `AnalyticsService.logAchievementUnlocked` was defined but never called
/// from `_checkBadges` in `results_screen.dart`. This test reads the source
/// file and asserts the call site exists and is wrapped in a loop over
/// `newBadges`, so the wiring cannot silently disappear again.
void main() {
  group('results_screen.dart -> AnalyticsService.logAchievementUnlocked wiring', () {
    late String source;

    setUpAll(() {
      source = File('lib/screens/results_screen.dart').readAsStringSync();
    });

    test('contains _checkBadges method', () {
      expect(
        source.contains('_checkBadges('),
        isTrue,
        reason: '_checkBadges must exist in results_screen.dart',
      );
    });

    test('contains a call to AnalyticsService().logAchievementUnlocked', () {
      expect(
        source.contains('AnalyticsService().logAchievementUnlocked('),
        isTrue,
        reason:
            'Firebase Analytics achievement_unlocked event must be fired '
            'from results_screen.dart when badges unlock (Phase 03 ANLT-01).',
      );
    });

    test('passes achievementId, tier, and category named args', () {
      expect(source.contains('achievementId: badge.achievementId'), isTrue,
          reason: 'logAchievementUnlocked must receive achievementId from the badge');
      expect(source.contains('tier: badge.tier'), isTrue,
          reason: 'logAchievementUnlocked must receive tier from the badge');
      expect(source.contains('category: badge.category'), isTrue,
          reason: 'logAchievementUnlocked must receive category from the badge');
    });

    test('iterates over newBadges so every unlock is logged', () {
      // Matches either `for (final badge in newBadges)` or
      // `for (var badge in newBadges)` to be tolerant of minor style changes.
      final loopPattern = RegExp(r'for\s*\(\s*(?:final|var)\s+badge\s+in\s+newBadges\s*\)');
      expect(
        loopPattern.hasMatch(source),
        isTrue,
        reason: 'logAchievementUnlocked must be invoked inside a loop over '
            'newBadges so every newly unlocked badge produces an event.',
      );
    });

    test('call site is inside _checkBadges (ordering check)', () {
      final checkBadgesIndex = source.indexOf('_checkBadges(');
      final logCallIndex = source.indexOf('AnalyticsService().logAchievementUnlocked(');
      expect(checkBadgesIndex, greaterThanOrEqualTo(0));
      expect(logCallIndex, greaterThan(checkBadgesIndex),
          reason: 'The logAchievementUnlocked call must appear after the '
              '_checkBadges declaration (i.e. inside its body).');
    });
  });
}
