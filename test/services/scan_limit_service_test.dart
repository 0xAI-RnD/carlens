import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carlens/services/scan_limit_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScanLimitService singleton', () {
    test('returns the same instance', () {
      final a = ScanLimitService();
      final b = ScanLimitService();
      expect(identical(a, b), isTrue);
    });

    test('batchSize constant is 5', () {
      expect(ScanLimitService.batchSize, 5);
    });
  });

  group('ScanLimitService counter behavior', () {
    setUp(() {
      // Re-seed an empty SharedPreferences store before each test so the
      // starting count is deterministic (fresh install state).
      SharedPreferences.setMockInitialValues({});
    });

    test('fresh install: remaining == 5, used == 0', () async {
      final service = ScanLimitService();
      expect(await service.getUsed(), 0);
      expect(await service.remaining(), 5);
      expect(await service.canScan(), isTrue);
    });

    test('consume once: remaining == 4', () async {
      final service = ScanLimitService();
      await service.consume();
      expect(await service.getUsed(), 1);
      expect(await service.remaining(), 4);
      expect(await service.canScan(), isTrue);
    });

    test('consume 5 times: remaining == 0, canScan == false', () async {
      final service = ScanLimitService();
      for (var i = 0; i < 5; i++) {
        await service.consume();
      }
      expect(await service.getUsed(), 5);
      expect(await service.remaining(), 0);
      expect(await service.canScan(), isFalse);
    });

    test('6th consume does not exceed batchSize (no negative remaining)',
        () async {
      final service = ScanLimitService();
      for (var i = 0; i < 6; i++) {
        await service.consume();
      }
      expect(await service.getUsed(), 5);
      expect(await service.remaining(), 0);
      expect(await service.canScan(), isFalse);
    });

    test('refill resets used to 0: remaining == 5, canScan == true', () async {
      final service = ScanLimitService();
      for (var i = 0; i < 5; i++) {
        await service.consume();
      }
      await service.refill();
      expect(await service.getUsed(), 0);
      expect(await service.remaining(), 5);
      expect(await service.canScan(), isTrue);
    });

    test('refill is repeatable: always resets to 5', () async {
      final service = ScanLimitService();
      await service.consume();
      await service.refill();
      expect(await service.remaining(), 5);
      await service.consume();
      await service.consume();
      await service.refill();
      expect(await service.remaining(), 5);
    });
  });

  group('ScanLimitService persistence', () {
    test('counter persists across a fresh SharedPreferences read (restart)',
        () async {
      // Simulate an app that had already consumed 3 scans.
      SharedPreferences.setMockInitialValues({'scan_limit_used': 3});
      final service = ScanLimitService();
      expect(await service.getUsed(), 3);
      expect(await service.remaining(), 2);

      // Consume one more, then simulate a "restart" by re-reading: the mock
      // store retains the written value until setMockInitialValues is called
      // again, so the persisted value reflects the consume.
      await service.consume();
      expect(await service.getUsed(), 4);
      expect(await service.remaining(), 1);
    });

    test('reads only its own SP key, independent from garage DB count',
        () async {
      // Even with an unrelated key present, remaining derives only from
      // scan_limit_used.
      SharedPreferences.setMockInitialValues({
        'scan_limit_used': 2,
        'some_garage_scan_count': 99,
      });
      final service = ScanLimitService();
      expect(await service.remaining(), 3);
    });
  });
}
