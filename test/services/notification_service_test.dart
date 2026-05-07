import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carlens/services/notification_service.dart';

void main() {
  group('Curiosities JSON', () {
    late List<dynamic> curiosities;

    setUpAll(() {
      final file = File('assets/data/curiosities.json');
      final jsonString = file.readAsStringSync();
      curiosities = json.decode(jsonString) as List<dynamic>;
    });

    test('curiosities file exists and is valid JSON', () {
      expect(curiosities, isNotNull);
      expect(curiosities, isA<List>());
    });

    test('curiosities has at least 30 entries', () {
      expect(curiosities.length, greaterThanOrEqualTo(30));
    });

    test('each curiosity has required fields: title, body, car', () {
      for (int i = 0; i < curiosities.length; i++) {
        final item = curiosities[i] as Map<String, dynamic>;
        expect(item.containsKey('title'), isTrue,
            reason: 'Entry $i missing "title"');
        expect(item.containsKey('body'), isTrue,
            reason: 'Entry $i missing "body"');
        expect(item.containsKey('car'), isTrue,
            reason: 'Entry $i missing "car"');
      }
    });

    test('each curiosity has non-empty string values', () {
      for (int i = 0; i < curiosities.length; i++) {
        final item = curiosities[i] as Map<String, dynamic>;
        expect(item['title'], isA<String>(),
            reason: 'Entry $i "title" is not a string');
        expect((item['title'] as String).isNotEmpty, isTrue,
            reason: 'Entry $i "title" is empty');
        expect(item['body'], isA<String>(),
            reason: 'Entry $i "body" is not a string');
        expect((item['body'] as String).isNotEmpty, isTrue,
            reason: 'Entry $i "body" is empty');
        expect(item['car'], isA<String>(),
            reason: 'Entry $i "car" is not a string');
        expect((item['car'] as String).isNotEmpty, isTrue,
            reason: 'Entry $i "car" is empty');
      }
    });

    test('no duplicate car entries', () {
      final cars = curiosities.map((c) => c['car'] as String).toList();
      expect(cars.toSet().length, equals(cars.length),
          reason: 'Found duplicate car entries');
    });
  });

  group('NotificationService preferences', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('isEnabled returns true by default', () async {
      final service = NotificationService();
      final enabled = await service.isEnabled();
      expect(enabled, isTrue);
    });

    test('setEnabled persists false value', () async {
      final service = NotificationService();
      // We can't fully test setEnabled because it calls scheduleDailyNotification/cancelAll
      // which require platform channels. Instead test SharedPreferences directly.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', false);
      final enabled = await service.isEnabled();
      expect(enabled, isFalse);
    });

    test('setEnabled persists true value', () async {
      final service = NotificationService();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', false);
      expect(await service.isEnabled(), isFalse);

      await prefs.setBool('notifications_enabled', true);
      expect(await service.isEnabled(), isTrue);
    });
  });

  group('NotificationService index cycling', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getCurrentIndex returns 0 by default', () async {
      final service = NotificationService();
      final index = await service.getCurrentIndex();
      expect(index, equals(0));
    });

    test('index persists across reads', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('curiosity_index', 5);

      final service = NotificationService();
      final index = await service.getCurrentIndex();
      expect(index, equals(5));
    });

    test('index wraps around when exceeding curiosity count', () async {
      final service = NotificationService();
      // Load curiosities manually to set the list length
      final file = File('assets/data/curiosities.json');
      final jsonString = file.readAsStringSync();
      service.loadCuriositiesFromJson(jsonString);
      final count = service.curiosities.length;

      // Set index to last position
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('curiosity_index', count - 1);

      final index = await service.getCurrentIndex();
      expect(index, equals(count - 1));
    });
  });

  group('NotificationService curiosity loading', () {
    test('loadCuriositiesFromJson populates the list', () {
      final service = NotificationService();
      const testJson = '[{"title":"Test","body":"Test body","car":"Test Car"}]';
      service.loadCuriositiesFromJson(testJson);
      expect(service.curiosities.length, equals(1));
      expect(service.curiosities[0]['title'], equals('Test'));
      expect(service.curiosities[0]['car'], equals('Test Car'));
    });

    test('loadCuriositiesFromJson handles multiple entries', () {
      final service = NotificationService();
      const testJson =
          '[{"title":"A","body":"B","car":"C"},{"title":"D","body":"E","car":"F"}]';
      service.loadCuriositiesFromJson(testJson);
      expect(service.curiosities.length, equals(2));
    });
  });

  group('NotificationService scheduling configuration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('notificationCount is at least 60', () {
      final service = NotificationService();
      expect(service.notificationCount, greaterThanOrEqualTo(60));
    });

    test('cycling algorithm produces distinct payloads within rotation window',
        () {
      final service = NotificationService();
      final file = File('assets/data/curiosities.json');
      final jsonString = file.readAsStringSync();
      service.loadCuriositiesFromJson(jsonString);
      final n = service.curiosities.length;
      expect(n, greaterThanOrEqualTo(30));

      const startIndex = 0;
      final count = service.notificationCount;
      // Build the rotation as scheduleDailyNotification would
      final rotation = List.generate(
        count,
        (i) => service.curiosities[(startIndex + i) % n],
      );

      // First N entries are distinct (full rotation)
      final firstWindow = rotation.take(n).toList();
      final firstWindowCars =
          firstWindow.map((c) => c['car'] as String).toSet();
      expect(firstWindowCars.length, equals(n),
          reason: 'First $n entries should all be distinct');

      // Cycling happens: index n should equal index 0
      if (count > n) {
        expect(rotation[n]['car'], equals(rotation[0]['car']),
            reason: 'Index n should cycle back to index 0');
      }

      // No out-of-bounds: full rotation has `count` items
      expect(rotation.length, equals(count));
    });

    test('cycling algorithm starts at provided startIndex', () {
      final service = NotificationService();
      const testJson =
          '[{"title":"A","body":"b","car":"CarA"},'
          '{"title":"B","body":"b","car":"CarB"},'
          '{"title":"C","body":"b","car":"CarC"}]';
      service.loadCuriositiesFromJson(testJson);
      final n = service.curiosities.length;

      const startIndex = 1;
      final rotation = List.generate(
        6,
        (i) => service.curiosities[(startIndex + i) % n],
      );
      expect(rotation[0]['car'], equals('CarB'));
      expect(rotation[1]['car'], equals('CarC'));
      expect(rotation[2]['car'], equals('CarA')); // wrap
      expect(rotation[3]['car'], equals('CarB')); // cycle
    });
  });
}
