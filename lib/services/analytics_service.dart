import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logScanCompleted({
    required String brand,
    required String model,
    required int year,
    required double confidence,
    required String source,
  }) async {
    await _analytics.logEvent(
      name: 'scan_completed',
      parameters: {
        'brand': _truncate(brand),
        'model': _truncate(model),
        'year': year,
        'confidence': confidence,
        'source': source,
      },
    );
  }

  Future<void> logAchievementUnlocked({
    required String achievementId,
    required String tier,
    required String category,
  }) async {
    await _analytics.logEvent(
      name: 'achievement_unlocked',
      parameters: {
        'achievement_id': achievementId,
        'tier': tier,
        'category': category,
      },
    );
  }

  Future<void> logCarShared({
    required String brand,
    required String model,
  }) async {
    await _analytics.logEvent(
      name: 'car_shared',
      parameters: {
        'brand': _truncate(brand),
        'model': _truncate(model),
      },
    );
  }

  Future<void> logAlternativeSwapped({
    required String originalBrand,
    required String swappedToBrand,
  }) async {
    await _analytics.logEvent(
      name: 'alternative_swapped',
      parameters: {
        'original_brand': _truncate(originalBrand),
        'swapped_to_brand': _truncate(swappedToBrand),
      },
    );
  }

  /// Truncate string to 100 chars max (Firebase Analytics parameter limit).
  String _truncate(String value) {
    return value.length > 100 ? value.substring(0, 100) : value;
  }
}
