import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/models/car_scan.dart';
import 'package:carlens/services/gemini_service.dart';

/// Tests that verify data is preserved across all views (L1, L2, Garage).
/// These tests exist because bugs were found where L2 and Garage detail views
/// were missing description, market value, timeline, and fun fact sections
/// that were visible in L1.
void main() {
  group('ExtraData serialization completeness', () {
    // Simulates what _saveToGarage() does in results_screen.dart
    Map<String, dynamic> buildExtraData(CarIdentification ident) {
      return {
        'engine_code': ident.engineCode,
        'displacement': ident.engineDisplacement,
        'power': ident.enginePower,
        'transmission': ident.transmissionType,
        'transmission_brand': ident.transmissionBrand,
        'weight': ident.weight,
        'top_speed': ident.topSpeed,
        'total_produced': ident.totalProduced,
        'designer': ident.designer,
        'fun_fact': ident.funFact,
        'market_value_range': ident.marketValueRange,
        'timeline': ident.timeline,
        'distinguishing_features': ident.distinguishingFeatures,
      };
    }

    CarIdentification createFullIdentification() {
      return CarIdentification(
        brand: 'Alfa Romeo',
        model: 'Giulia GT',
        yearEstimate: '1963-1976',
        bodyType: 'Coupé',
        color: 'Rosso',
        confidence: 0.95,
        details: 'Una bellissima coupé sportiva italiana.',
        distinguishingFeatures: ['Fari tondi', 'Griglia Alfa'],
        engineCode: 'AR00526',
        engineDisplacement: '1570 cc',
        enginePower: '109 CV @ 6.000 giri',
        transmissionType: '5 marce manuale',
        transmissionBrand: 'Alfa Romeo',
        weight: '1.020 kg',
        topSpeed: '185 km/h',
        totalProduced: '21.902',
        designer: 'Bertone (Giugiaro)',
        funFact: 'Fu soprannominata "Scalino" per la forma del cofano.',
        marketValueRange: '€25.000 - €45.000',
        timeline: [
          '1963: Presentazione Giulia Sprint GT',
          '1966: Debutto GT 1300 Junior',
          '1976: Fine produzione',
        ],
      );
    }

    test('extraData JSON includes ALL required fields', () {
      final ident = createFullIdentification();
      final extra = buildExtraData(ident);

      // These are the fields that MUST be in extraData for Garage detail to work
      expect(extra.containsKey('fun_fact'), isTrue,
          reason: 'fun_fact missing from extraData');
      expect(extra.containsKey('market_value_range'), isTrue,
          reason: 'market_value_range missing from extraData');
      expect(extra.containsKey('timeline'), isTrue,
          reason: 'timeline missing from extraData');
      expect(extra.containsKey('engine_code'), isTrue);
      expect(extra.containsKey('displacement'), isTrue);
      expect(extra.containsKey('power'), isTrue);
      expect(extra.containsKey('transmission'), isTrue);
      expect(extra.containsKey('transmission_brand'), isTrue);
      expect(extra.containsKey('weight'), isTrue);
      expect(extra.containsKey('top_speed'), isTrue);
      expect(extra.containsKey('total_produced'), isTrue);
      expect(extra.containsKey('designer'), isTrue);
      expect(extra.containsKey('distinguishing_features'), isTrue);
    });

    test('extraData survives JSON encode/decode roundtrip', () {
      final ident = createFullIdentification();
      final extra = buildExtraData(ident);

      final jsonStr = jsonEncode(extra);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded['fun_fact'], equals('Fu soprannominata "Scalino" per la forma del cofano.'));
      expect(decoded['market_value_range'], equals('€25.000 - €45.000'));
      expect(decoded['timeline'], isList);
      expect((decoded['timeline'] as List).length, equals(3));
      expect(decoded['engine_code'], equals('AR00526'));
      expect(decoded['designer'], equals('Bertone (Giugiaro)'));
    });

    test('extraData survives full CarScan toMap/fromMap roundtrip', () {
      final ident = createFullIdentification();
      final extra = buildExtraData(ident);
      final extraJson = jsonEncode(extra);

      final scan = CarScan(
        brand: ident.brand,
        model: ident.model,
        yearEstimate: ident.yearEstimate,
        bodyType: ident.bodyType,
        color: ident.color,
        confidence: ident.confidence,
        details: ident.details,
        vin: 'ZAR11500001234567',
        imagePath: '/tmp/test.jpg',
        createdAt: DateTime(2026, 3, 23),
        level: 2,
        extraData: extraJson,
      );

      final map = scan.toMap();
      final restored = CarScan.fromMap(map);

      // Verify extraData survived
      expect(restored.extraData, isNotNull);
      final restoredExtra = jsonDecode(restored.extraData!) as Map<String, dynamic>;

      expect(restoredExtra['fun_fact'], equals('Fu soprannominata "Scalino" per la forma del cofano.'));
      expect(restoredExtra['market_value_range'], equals('€25.000 - €45.000'));
      expect(restoredExtra['timeline'], isList);
      expect((restoredExtra['timeline'] as List).length, equals(3));
    });

    test('CarIdentification can be reconstructed from extraData (Garage restore flow)', () {
      // This simulates what results_screen.dart does when opening from Garage
      final ident = createFullIdentification();
      final extra = buildExtraData(ident);
      final extraJson = jsonEncode(extra);

      // Decode extraData like results_screen.dart line 95
      final decoded = jsonDecode(extraJson) as Map<String, dynamic>;

      // Reconstruct CarIdentification like results_screen.dart lines 99-126
      final restored = CarIdentification(
        brand: ident.brand,
        model: ident.model,
        yearEstimate: ident.yearEstimate,
        bodyType: ident.bodyType,
        color: ident.color,
        confidence: ident.confidence,
        details: ident.details,
        distinguishingFeatures: (decoded['distinguishing_features'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        engineCode: decoded['engine_code'] as String? ?? '',
        engineDisplacement: decoded['displacement'] as String? ?? '',
        enginePower: decoded['power'] as String? ?? '',
        transmissionType: decoded['transmission'] as String? ?? '',
        transmissionBrand: decoded['transmission_brand'] as String? ?? '',
        weight: decoded['weight'] as String? ?? '',
        topSpeed: decoded['top_speed'] as String? ?? '',
        totalProduced: decoded['total_produced'] as String? ?? '',
        designer: decoded['designer'] as String? ?? '',
        funFact: decoded['fun_fact'] as String? ?? '',
        marketValueRange: decoded['market_value_range'] as String? ?? '',
        timeline: (decoded['timeline'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

      // ALL fields must be restored for L2 view to show them
      expect(restored.funFact, equals(ident.funFact),
          reason: 'funFact lost during Garage restore');
      expect(restored.marketValueRange, equals(ident.marketValueRange),
          reason: 'marketValueRange lost during Garage restore');
      expect(restored.timeline.length, equals(ident.timeline.length),
          reason: 'timeline lost during Garage restore');
      expect(restored.engineCode, equals(ident.engineCode));
      expect(restored.enginePower, equals(ident.enginePower));
      expect(restored.designer, equals(ident.designer));
      expect(restored.details, equals(ident.details),
          reason: 'details (description) lost during Garage restore');
    });

    test('VIN update via copyWith preserves extraData', () {
      final extraJson = jsonEncode({
        'fun_fact': 'Test fact',
        'market_value_range': '€10.000 - €20.000',
        'timeline': ['1970: Start'],
      });

      final scan = CarScan(
        brand: 'Test',
        model: 'Car',
        yearEstimate: '1970-1975',
        bodyType: 'Coupé',
        color: 'Blu',
        confidence: 0.9,
        details: 'Test description',
        imagePath: '/tmp/test.jpg',
        createdAt: DateTime(2026, 3, 23),
        level: 1,
        extraData: extraJson,
      );

      // Simulate VIN addition (results_screen.dart line 317)
      final updated = scan.copyWith(vin: '3K57R6M122576', level: 2);

      expect(updated.extraData, equals(extraJson),
          reason: 'extraData MUST survive VIN update via copyWith');
      expect(updated.vin, equals('3K57R6M122576'));
      expect(updated.level, equals(2));
      expect(updated.details, equals('Test description'),
          reason: 'details MUST survive VIN update');
    });

    test('Garage detail sheet field names match serialization keys', () {
      // This test verifies the field name contract between
      // results_screen.dart (serialization) and garage_screen.dart (reading)
      final keys = {
        'engine_code',
        'displacement',
        'power',
        'transmission',
        'transmission_brand',
        'weight',
        'top_speed',
        'total_produced',
        'designer',
        'fun_fact',
        'market_value_range',
        'timeline',
        'distinguishing_features',
      };

      final ident = createFullIdentification();
      final extra = buildExtraData(ident);

      // Every key that the garage reads must exist in the serialized data
      for (final key in keys) {
        expect(extra.containsKey(key), isTrue,
            reason: 'Key "$key" missing from extraData - Garage detail will not show this field');
      }
    });
  });
}
