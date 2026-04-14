import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/models/achievement.dart';

void main() {
  Map<String, dynamic> _fullMap({int? unlockedAt}) {
    return {
      'id': 1,
      'achievement_id': 'scans_base',
      'category': 'scans',
      'tier': 'base',
      'threshold': 1,
      'unlocked_at': unlockedAt,
    };
  }

  group('Achievement.fromMap', () {
    test('parses all fields from a complete map', () {
      final ts = DateTime(2026, 4, 14).millisecondsSinceEpoch;
      final a = Achievement.fromMap(_fullMap(unlockedAt: ts));

      expect(a.id, 1);
      expect(a.achievementId, 'scans_base');
      expect(a.category, 'scans');
      expect(a.tier, 'base');
      expect(a.threshold, 1);
      expect(a.unlockedAt, DateTime.fromMillisecondsSinceEpoch(ts));
    });

    test('unlocked_at null stays null', () {
      final a = Achievement.fromMap(_fullMap());
      expect(a.unlockedAt, isNull);
    });

    test('parses brands_gold correctly', () {
      final a = Achievement.fromMap({
        'id': 8,
        'achievement_id': 'brands_gold',
        'category': 'brands',
        'tier': 'gold',
        'threshold': 30,
        'unlocked_at': null,
      });
      expect(a.achievementId, 'brands_gold');
      expect(a.threshold, 30);
    });
  });

  group('Achievement.toMap', () {
    test('round-trip locked achievement', () {
      final a = Achievement(
        id: 2,
        achievementId: 'eras_silver',
        category: 'eras',
        tier: 'silver',
        threshold: 4,
      );
      final map = a.toMap();

      expect(map['id'], 2);
      expect(map['achievement_id'], 'eras_silver');
      expect(map['category'], 'eras');
      expect(map['tier'], 'silver');
      expect(map['threshold'], 4);
      expect(map['unlocked_at'], isNull);
    });

    test('round-trip unlocked achievement preserves timestamp', () {
      final ts = DateTime(2026, 4, 14, 10, 0, 0);
      final a = Achievement(
        id: 3,
        achievementId: 'scans_bronze',
        category: 'scans',
        tier: 'bronze',
        threshold: 10,
        unlockedAt: ts,
      );
      final map = a.toMap();

      expect(map['unlocked_at'], ts.millisecondsSinceEpoch);
    });

    test('id omitted from map when null', () {
      final a = Achievement(
        achievementId: 'scans_base',
        category: 'scans',
        tier: 'base',
        threshold: 1,
      );
      final map = a.toMap();
      expect(map.containsKey('id'), isFalse);
    });

    test('fromMap → toMap round-trip is lossless', () {
      final ts = DateTime(2026, 1, 1).millisecondsSinceEpoch;
      final original = _fullMap(unlockedAt: ts);
      final a = Achievement.fromMap(original);
      final result = a.toMap();

      expect(result['achievement_id'], original['achievement_id']);
      expect(result['category'], original['category']);
      expect(result['tier'], original['tier']);
      expect(result['threshold'], original['threshold']);
      expect(result['unlocked_at'], original['unlocked_at']);
    });
  });

  group('Achievement.copyWith', () {
    test('copyWith replaces only specified fields', () {
      final ts = DateTime(2026, 4, 14);
      final a = Achievement(
        id: 1,
        achievementId: 'scans_base',
        category: 'scans',
        tier: 'base',
        threshold: 1,
      );
      final unlocked = a.copyWith(unlockedAt: ts);

      expect(unlocked.achievementId, 'scans_base');
      expect(unlocked.threshold, 1);
      expect(unlocked.unlockedAt, ts);
    });

    test('copyWith without args returns equivalent object', () {
      final a = Achievement(
        id: 5,
        achievementId: 'brands_bronze',
        category: 'brands',
        tier: 'bronze',
        threshold: 5,
      );
      final copy = a.copyWith();

      expect(copy.achievementId, a.achievementId);
      expect(copy.category, a.category);
      expect(copy.tier, a.tier);
      expect(copy.threshold, a.threshold);
    });
  });

  group('Achievement.isUnlocked', () {
    test('locked when unlockedAt is null', () {
      final a = Achievement(
        achievementId: 'scans_base',
        category: 'scans',
        tier: 'base',
        threshold: 1,
      );
      expect(a.isUnlocked, isFalse);
    });

    test('unlocked when unlockedAt is set', () {
      final a = Achievement(
        achievementId: 'scans_base',
        category: 'scans',
        tier: 'base',
        threshold: 1,
        unlockedAt: DateTime(2026, 4, 14),
      );
      expect(a.isUnlocked, isTrue);
    });
  });

  group('Achievement equality', () {
    test('two achievements with same achievementId are equal', () {
      final a = Achievement(achievementId: 'scans_base', category: 'scans', tier: 'base', threshold: 1);
      final b = Achievement(achievementId: 'scans_base', category: 'scans', tier: 'base', threshold: 1, id: 99);
      expect(a, equals(b));
    });

    test('two achievements with different achievementId are not equal', () {
      final a = Achievement(achievementId: 'scans_base', category: 'scans', tier: 'base', threshold: 1);
      final b = Achievement(achievementId: 'scans_bronze', category: 'scans', tier: 'bronze', threshold: 10);
      expect(a, isNot(equals(b)));
    });
  });
}
