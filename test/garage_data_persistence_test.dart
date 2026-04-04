import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/models/car_scan.dart';

/// Helper to create a fully populated CarScan for testing.
CarScan _makeScan({
  int? id,
  String brand = 'Alfa Romeo',
  String model = 'Giulia Sprint GT',
  String yearEstimate = '1965-1969',
  String bodyType = 'Coupe',
  String color = 'Rosso',
  double confidence = 0.92,
  String details = 'Classic Italian coupe',
  String? vin,
  double? originalityScore,
  String? originalityReport,
  String imagePath = '/photos/alfa.jpg',
  DateTime? createdAt,
  int level = 2,
  String? extraData,
}) {
  return CarScan(
    id: id,
    brand: brand,
    model: model,
    yearEstimate: yearEstimate,
    bodyType: bodyType,
    color: color,
    confidence: confidence,
    details: details,
    vin: vin,
    originalityScore: originalityScore,
    originalityReport: originalityReport,
    imagePath: imagePath,
    createdAt: createdAt ?? DateTime(2026, 3, 23, 10, 0),
    level: level,
    extraData: extraData,
  );
}

void main() {
  group('CarScan.toMap()', () {
    test('includes all fields', () {
      final scan = _makeScan(
        id: 1,
        vin: 'AR10548300123',
        originalityScore: 85.0,
        originalityReport: 'Original engine confirmed',
        extraData: '{"specs":{}}',
      );
      final map = scan.toMap();

      expect(map['id'], 1);
      expect(map['brand'], 'Alfa Romeo');
      expect(map['model'], 'Giulia Sprint GT');
      expect(map['year_estimate'], '1965-1969');
      expect(map['body_type'], 'Coupe');
      expect(map['color'], 'Rosso');
      expect(map['confidence'], 0.92);
      expect(map['details'], 'Classic Italian coupe');
      expect(map['vin'], 'AR10548300123');
      expect(map['originality_score'], 85.0);
      expect(map['originality_report'], 'Original engine confirmed');
      expect(map['image_path'], '/photos/alfa.jpg');
      expect(map['created_at'], isA<int>());
      expect(map['level'], 2);
      expect(map['extra_data'], '{"specs":{}}');
    });
  });

  group('CarScan.fromMap()', () {
    test('restores all fields from map', () {
      final now = DateTime(2026, 3, 23, 12, 0);
      final map = {
        'id': 5,
        'brand': 'Ferrari',
        'model': '308 GTS',
        'year_estimate': '1977-1985',
        'body_type': 'Targa',
        'color': 'Rosso Corsa',
        'confidence': 0.98,
        'details': 'Iconic mid-engine V8',
        'vin': 'ZFFAA02A1A0012345',
        'originality_score': 90.0,
        'originality_report': 'All matching',
        'image_path': '/photos/ferrari.jpg',
        'created_at': now.millisecondsSinceEpoch,
        'level': 3,
        'extra_data': '{"fun_fact":"Magnum PI"}',
      };

      final scan = CarScan.fromMap(map);

      expect(scan.id, 5);
      expect(scan.brand, 'Ferrari');
      expect(scan.model, '308 GTS');
      expect(scan.yearEstimate, '1977-1985');
      expect(scan.bodyType, 'Targa');
      expect(scan.color, 'Rosso Corsa');
      expect(scan.confidence, 0.98);
      expect(scan.details, 'Iconic mid-engine V8');
      expect(scan.vin, 'ZFFAA02A1A0012345');
      expect(scan.originalityScore, 90.0);
      expect(scan.originalityReport, 'All matching');
      expect(scan.imagePath, '/photos/ferrari.jpg');
      expect(scan.createdAt, now);
      expect(scan.level, 3);
      expect(scan.extraData, '{"fun_fact":"Magnum PI"}');
    });
  });

  group('CarScan extraData handling', () {
    test('extraData JSON with specs, timeline, fun_fact, market_value roundtrips', () {
      final extraJson = jsonEncode({
        'specs': {
          'engine_code': 'AR 00526',
          'displacement': '1570 cc',
        },
        'timeline': ['1963: Debutto', '1976: Fine produzione'],
        'fun_fact': 'Designed by Giugiaro',
        'market_value': '25000-45000',
      });

      final scan = _makeScan(id: 10, extraData: extraJson);
      final map = scan.toMap();
      final restored = CarScan.fromMap(map);

      expect(restored.extraData, extraJson);

      final parsed = jsonDecode(restored.extraData!) as Map<String, dynamic>;
      expect(parsed['specs']['engine_code'], 'AR 00526');
      expect(parsed['timeline'], hasLength(2));
      expect(parsed['fun_fact'], 'Designed by Giugiaro');
      expect(parsed['market_value'], '25000-45000');
    });

    test('toMap -> fromMap roundtrip preserves extraData', () {
      final extra = '{"key":"value","nested":{"a":1}}';
      final scan = _makeScan(id: 20, extraData: extra);
      final restored = CarScan.fromMap(scan.toMap());

      expect(restored.extraData, extra);
    });

    test('null extraData does not crash', () {
      final scan = _makeScan(extraData: null);
      final map = scan.toMap();
      final restored = CarScan.fromMap(map);

      expect(restored.extraData, isNull);
    });

    test('empty extraData string does not crash', () {
      final scan = _makeScan(extraData: '');
      final map = scan.toMap();
      final restored = CarScan.fromMap(map);

      expect(restored.extraData, '');
    });
  });

  group('CarScan.copyWith()', () {
    test('preserves extraData when not overridden', () {
      final original = _makeScan(extraData: '{"test":true}');
      final copied = original.copyWith(brand: 'Lancia');

      expect(copied.brand, 'Lancia');
      expect(copied.extraData, '{"test":true}');
    });
  });

  group('CarScan level field', () {
    test('level 1 stored and restored correctly', () {
      final scan = _makeScan(level: 1);
      final restored = CarScan.fromMap(scan.toMap());
      expect(restored.level, 1);
    });

    test('level 2 stored and restored correctly', () {
      final scan = _makeScan(level: 2);
      final restored = CarScan.fromMap(scan.toMap());
      expect(restored.level, 2);
    });

    test('level 3 stored and restored correctly', () {
      final scan = _makeScan(level: 3);
      final restored = CarScan.fromMap(scan.toMap());
      expect(restored.level, 3);
    });
  });

  group('CarScan VIN persistence', () {
    test('VIN field persists correctly through toMap/fromMap', () {
      final scan = _makeScan(vin: 'ZAR11500006000001');
      final map = scan.toMap();
      final restored = CarScan.fromMap(map);

      expect(restored.vin, 'ZAR11500006000001');
    });

    test('null VIN persists correctly through toMap/fromMap', () {
      final scan = _makeScan(vin: null);
      final map = scan.toMap();
      final restored = CarScan.fromMap(map);

      expect(restored.vin, isNull);
    });
  });
}
