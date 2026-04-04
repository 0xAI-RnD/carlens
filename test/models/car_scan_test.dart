import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/models/car_scan.dart';

void main() {
  // A fully-populated map that mirrors what the database would return.
  Map<String, dynamic> _fullMap() {
    return {
      'id': 42,
      'brand': 'Alfa Romeo',
      'model': 'Giulia Sprint GT',
      'year_estimate': '1965-1969',
      'body_type': 'Coupe',
      'color': 'Rosso',
      'confidence': 0.92,
      'details': 'A classic Italian coupe.',
      'vin': 'ZAR11500001234567',
      'originality_score': 87.5,
      'originality_report': 'Mostly original with minor modifications.',
      'image_path': '/images/giulia.jpg',
      'created_at': 1700000000000,
      'level': 3,
      'extra_data': '{"funFact":"First mass-produced car with disc brakes."}',
    };
  }

  group('CarScan.fromMap', () {
    test('parses all fields from a complete map', () {
      final scan = CarScan.fromMap(_fullMap());

      expect(scan.id, 42);
      expect(scan.brand, 'Alfa Romeo');
      expect(scan.model, 'Giulia Sprint GT');
      expect(scan.yearEstimate, '1965-1969');
      expect(scan.bodyType, 'Coupe');
      expect(scan.color, 'Rosso');
      expect(scan.confidence, 0.92);
      expect(scan.details, 'A classic Italian coupe.');
      expect(scan.vin, 'ZAR11500001234567');
      expect(scan.originalityScore, 87.5);
      expect(scan.originalityReport, 'Mostly original with minor modifications.');
      expect(scan.imagePath, '/images/giulia.jpg');
      expect(scan.createdAt, DateTime.fromMillisecondsSinceEpoch(1700000000000));
      expect(scan.level, 3);
      expect(scan.extraData, contains('funFact'));
    });

    test('handles null optional fields (vin, originalityScore, originalityReport, extraData)', () {
      final map = _fullMap();
      map['id'] = null;
      map['vin'] = null;
      map['originality_score'] = null;
      map['originality_report'] = null;
      map['extra_data'] = null;

      final scan = CarScan.fromMap(map);
      expect(scan.id, isNull);
      expect(scan.vin, isNull);
      expect(scan.originalityScore, isNull);
      expect(scan.originalityReport, isNull);
      expect(scan.extraData, isNull);
    });

    test('confidence accepts int and converts to double', () {
      final map = _fullMap();
      map['confidence'] = 1; // int instead of double

      final scan = CarScan.fromMap(map);
      expect(scan.confidence, 1.0);
      expect(scan.confidence, isA<double>());
    });

    test('originality_score accepts int and converts to double', () {
      final map = _fullMap();
      map['originality_score'] = 90;

      final scan = CarScan.fromMap(map);
      expect(scan.originalityScore, 90.0);
      expect(scan.originalityScore, isA<double>());
    });
  });

  group('CarScan.toMap', () {
    test('round-trips through fromMap/toMap', () {
      final original = _fullMap();
      final scan = CarScan.fromMap(original);
      final output = scan.toMap();

      expect(output['id'], 42);
      expect(output['brand'], 'Alfa Romeo');
      expect(output['model'], 'Giulia Sprint GT');
      expect(output['year_estimate'], '1965-1969');
      expect(output['body_type'], 'Coupe');
      expect(output['color'], 'Rosso');
      expect(output['confidence'], 0.92);
      expect(output['details'], 'A classic Italian coupe.');
      expect(output['vin'], 'ZAR11500001234567');
      expect(output['originality_score'], 87.5);
      expect(output['originality_report'], 'Mostly original with minor modifications.');
      expect(output['image_path'], '/images/giulia.jpg');
      expect(output['created_at'], 1700000000000);
      expect(output['level'], 3);
      expect(output['extra_data'], contains('funFact'));
    });

    test('omits id when null', () {
      final map = _fullMap();
      map.remove('id');
      map['id'] = null;

      final scan = CarScan.fromMap(map);
      final output = scan.toMap();

      expect(output.containsKey('id'), false);
    });

    test('includes null optional fields as null values', () {
      final map = _fullMap();
      map['vin'] = null;
      map['originality_score'] = null;
      map['originality_report'] = null;
      map['extra_data'] = null;

      final scan = CarScan.fromMap(map);
      final output = scan.toMap();

      expect(output.containsKey('vin'), true);
      expect(output['vin'], isNull);
      expect(output.containsKey('originality_score'), true);
      expect(output['originality_score'], isNull);
    });
  });

  group('CarScan.toMap/fromMap round-trip', () {
    test('full round-trip preserves data', () {
      final scan1 = CarScan.fromMap(_fullMap());
      final scan2 = CarScan.fromMap(scan1.toMap());

      expect(scan2.id, scan1.id);
      expect(scan2.brand, scan1.brand);
      expect(scan2.model, scan1.model);
      expect(scan2.yearEstimate, scan1.yearEstimate);
      expect(scan2.bodyType, scan1.bodyType);
      expect(scan2.color, scan1.color);
      expect(scan2.confidence, scan1.confidence);
      expect(scan2.details, scan1.details);
      expect(scan2.vin, scan1.vin);
      expect(scan2.originalityScore, scan1.originalityScore);
      expect(scan2.originalityReport, scan1.originalityReport);
      expect(scan2.imagePath, scan1.imagePath);
      expect(scan2.createdAt, scan1.createdAt);
      expect(scan2.level, scan1.level);
      expect(scan2.extraData, scan1.extraData);
    });
  });

  group('CarScan.copyWith', () {
    test('copies all fields when all provided', () {
      final scan = CarScan.fromMap(_fullMap());
      final newDate = DateTime(2024, 6, 15);
      final copied = scan.copyWith(
        id: 99,
        brand: 'Ferrari',
        model: '308 GTB',
        yearEstimate: '1975-1985',
        bodyType: 'Berlinetta',
        color: 'Rosso Corsa',
        confidence: 0.99,
        details: 'A Pininfarina masterpiece.',
        vin: 'ZFFAA12B0H0123456',
        originalityScore: 95.0,
        originalityReport: 'Fully original.',
        imagePath: '/images/308.jpg',
        createdAt: newDate,
        level: 5,
        extraData: '{"new":"data"}',
      );

      expect(copied.id, 99);
      expect(copied.brand, 'Ferrari');
      expect(copied.model, '308 GTB');
      expect(copied.yearEstimate, '1975-1985');
      expect(copied.bodyType, 'Berlinetta');
      expect(copied.color, 'Rosso Corsa');
      expect(copied.confidence, 0.99);
      expect(copied.details, 'A Pininfarina masterpiece.');
      expect(copied.vin, 'ZFFAA12B0H0123456');
      expect(copied.originalityScore, 95.0);
      expect(copied.originalityReport, 'Fully original.');
      expect(copied.imagePath, '/images/308.jpg');
      expect(copied.createdAt, newDate);
      expect(copied.level, 5);
      expect(copied.extraData, '{"new":"data"}');
    });

    test('preserves original values when no arguments provided', () {
      final scan = CarScan.fromMap(_fullMap());
      final copied = scan.copyWith();

      expect(copied.id, scan.id);
      expect(copied.brand, scan.brand);
      expect(copied.model, scan.model);
      expect(copied.confidence, scan.confidence);
      expect(copied.vin, scan.vin);
      expect(copied.level, scan.level);
    });

    test('partial copyWith overrides only specified fields', () {
      final scan = CarScan.fromMap(_fullMap());
      final copied = scan.copyWith(brand: 'Lancia', level: 7);

      expect(copied.brand, 'Lancia');
      expect(copied.level, 7);
      // Everything else remains unchanged
      expect(copied.model, scan.model);
      expect(copied.id, scan.id);
      expect(copied.vin, scan.vin);
      expect(copied.confidence, scan.confidence);
    });
  });

  group('CarScan date serialization', () {
    test('stores date as milliseconds since epoch', () {
      final date = DateTime(2024, 1, 15, 10, 30, 0);
      final scan = CarScan(
        brand: 'Fiat',
        model: '500',
        yearEstimate: '1957-1975',
        bodyType: 'Sedan',
        color: 'Celeste',
        confidence: 0.85,
        details: 'A Fiat 500.',
        imagePath: '/images/500.jpg',
        createdAt: date,
        level: 1,
      );

      final map = scan.toMap();
      expect(map['created_at'], date.millisecondsSinceEpoch);
    });

    test('restores date from milliseconds since epoch', () {
      final millis = 1705312200000; // Some fixed timestamp
      final map = _fullMap();
      map['created_at'] = millis;

      final scan = CarScan.fromMap(map);
      expect(scan.createdAt, DateTime.fromMillisecondsSinceEpoch(millis));
      expect(scan.createdAt.millisecondsSinceEpoch, millis);
    });
  });

  group('CarScan equality and hashCode', () {
    test('two scans with same id are equal', () {
      final scan1 = CarScan.fromMap(_fullMap());
      final map2 = _fullMap();
      map2['brand'] = 'Ferrari'; // different brand, same id
      final scan2 = CarScan.fromMap(map2);

      expect(scan1 == scan2, true);
    });

    test('two scans with different ids are not equal', () {
      final scan1 = CarScan.fromMap(_fullMap());
      final map2 = _fullMap();
      map2['id'] = 99;
      final scan2 = CarScan.fromMap(map2);

      expect(scan1 == scan2, false);
    });

    test('same id produces same hashCode', () {
      final scan1 = CarScan.fromMap(_fullMap());
      final map2 = _fullMap();
      map2['model'] = 'Different Model';
      final scan2 = CarScan.fromMap(map2);

      expect(scan1.hashCode, scan2.hashCode);
    });

    test('null id equality', () {
      final map1 = _fullMap();
      map1['id'] = null;
      final map2 = _fullMap();
      map2['id'] = null;

      final scan1 = CarScan.fromMap(map1);
      final scan2 = CarScan.fromMap(map2);

      // Both have null id => null == null is true
      expect(scan1 == scan2, true);
      expect(scan1.hashCode, scan2.hashCode);
    });

    test('identical reference is equal', () {
      final scan = CarScan.fromMap(_fullMap());
      expect(scan == scan, true);
    });

    test('not equal to non-CarScan object', () {
      final scan = CarScan.fromMap(_fullMap());
      // ignore: unrelated_type_equality_checks
      expect(scan == 'not a CarScan', false);
    });
  });

  group('CarScan.toString', () {
    test('contains key identifying information', () {
      final scan = CarScan.fromMap(_fullMap());
      final s = scan.toString();
      expect(s, contains('Alfa Romeo'));
      expect(s, contains('Giulia Sprint GT'));
      expect(s, contains('42'));
      expect(s, contains('0.92'));
    });
  });
}
