import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../services/database_service.dart';
import '../services/gemini_service.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  /// Checks all badge conditions after a scan and unlocks any newly earned badges.
  /// Returns the list of NEWLY unlocked achievements (for banner display).
  ///
  /// IMPORTANT: This must be called AFTER the scan has been saved to DB so that
  /// getScanCount() and other stat queries reflect the current scan.
  Future<List<Achievement>> checkAndUnlock(
      CarIdentification identification) async {
    final db = DatabaseService();

    // Get current stats from DB (scan is already saved at this point)
    final scanCount = await db.getScanCount();

    // Check if current brand is new
    final brandOccurrences =
        await db.getBrandOccurrenceCount(identification.brand);
    final isNewBrand = brandOccurrences == 0;
    final distinctBrandCount =
        await db.getDistinctBrandCount() + (isNewBrand ? 1 : 0);

    // Check if current era is new
    final currentDecade = _parseDecade(identification.yearEstimate);
    var distinctEraCount = await db.getDistinctEraCount();
    if (currentDecade != null) {
      final hasDecade = await db.hasDecadeInScans(currentDecade);
      if (!hasDecade) {
        distinctEraCount += 1;
      }
    }

    // Build stats map
    final stats = {
      'scans': scanCount,
      'brands': distinctBrandCount,
      'eras': distinctEraCount,
    };

    // Check all achievements and unlock newly earned ones
    final allAchievements = await db.getAchievements();
    final newlyUnlocked = <Achievement>[];
    final now = DateTime.now();

    for (final achievement in allAchievements) {
      if (achievement.isUnlocked) continue;

      final currentStat = stats[achievement.category] ?? 0;
      if (currentStat >= achievement.threshold) {
        await db.unlockAchievement(achievement.achievementId, now);
        newlyUnlocked.add(achievement.copyWith(unlockedAt: now));
      }
    }

    return newlyUnlocked;
  }

  /// Parses a decade from a year estimate string.
  /// Handles formats: "1967", "1965-1970", "circa 1960", "anni '60"
  /// Returns decade as e.g. 1960, 1970, etc. or null if parsing fails.
  @visibleForTesting
  int? parseDecadeForTest(String yearEstimate) => _parseDecade(yearEstimate);

  int? _parseDecade(String yearEstimate) {
    final match = RegExp(r'(1[89]\d{2}|20\d{2})').firstMatch(yearEstimate);
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    return (year ~/ 10) * 10;
  }
}
