import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/services/gemini_service.dart';

void main() {
  group('CarIdentification.keyDifference', () {
    test('parses key_difference from JSON', () {
      final json = {
        'brand': 'Alfa Romeo',
        'model': 'Giulia Sprint GT',
        'year_estimate': '1963-1966',
        'body_type': 'Coupé',
        'color': 'Giallo',
        'confidence': 0.10,
        'details': 'Alternativa.',
        'distinguishing_features': ['calandra diversa'],
        'key_difference':
            'La Sprint GT ha la calandra più stretta e i paraurti cromati diversi',
        'specs': <String, dynamic>{},
        'fun_fact': '',
        'market_value_range': '',
        'timeline': [],
      };

      final car = CarIdentification.fromJson(json);
      expect(car.keyDifference,
          'La Sprint GT ha la calandra più stretta e i paraurti cromati diversi');
    });

    test('defaults to empty string when key_difference is missing', () {
      final json = {
        'brand': 'Fiat',
        'model': '500',
        'year_estimate': '1957',
        'body_type': 'Berlina',
        'color': 'Bianco',
        'confidence': 0.9,
        'details': '',
        'distinguishing_features': [],
        'specs': <String, dynamic>{},
      };

      final car = CarIdentification.fromJson(json);
      expect(car.keyDifference, '');
    });

    test('toJson includes key_difference', () {
      final car = CarIdentification(
        brand: 'Alfa Romeo',
        model: 'GT',
        yearEstimate: '1968',
        bodyType: 'Coupé',
        color: 'Rosso',
        confidence: 0.8,
        details: '',
        distinguishingFeatures: [],
        keyDifference: 'Differenza qui',
      );

      final json = car.toJson();
      expect(json['key_difference'], 'Differenza qui');
    });
  });

  group('GeminiService._parseCarIdentifications', () {
    // Access the static method via a helper since it's private.
    // We test indirectly through CarIdentification.fromJson and the parsing logic.

    test('parses response with matches array (multiple matches)', () {
      final responseJson = {
        'matches': [
          {
            'brand': 'Alfa Romeo',
            'model': 'GT 1300 Junior',
            'year_estimate': '1968-1972',
            'body_type': 'Coupé',
            'color': 'Giallo Ocra',
            'confidence': 0.85,
            'details': 'Descrizione principale.',
            'distinguishing_features': ['fari tondi', 'calandra a V'],
            'key_difference': '',
            'specs': {
              'engine_code': 'AR 00526',
              'displacement': '1290 cc',
              'power': '89 CV',
              'transmission': '5 marce manuale',
              'transmission_brand': 'Alfa Romeo',
              'weight': '960 kg',
              'top_speed': '170 km/h',
              'total_produced': '91.000',
              'designer': 'Bertone',
            },
            'fun_fact': 'Curiosità 1',
            'market_value_range': '€30.000 - €50.000',
            'timeline': ['1968: Lancio'],
          },
          {
            'brand': 'Alfa Romeo',
            'model': 'Giulia Sprint GT',
            'year_estimate': '1963-1966',
            'body_type': 'Coupé',
            'color': 'Giallo',
            'confidence': 0.10,
            'details': 'Alternativa 1.',
            'distinguishing_features': ['calandra diversa'],
            'key_difference':
                'La Sprint GT ha la calandra più stretta e paraurti diversi',
            'specs': <String, dynamic>{},
            'fun_fact': '',
            'market_value_range': '',
            'timeline': [],
          },
          {
            'brand': 'Lancia',
            'model': 'Fulvia Coupé',
            'year_estimate': '1965-1976',
            'body_type': 'Coupé',
            'color': 'Giallo',
            'confidence': 0.05,
            'details': 'Alternativa 2.',
            'distinguishing_features': ['fari rettangolari'],
            'key_difference': 'La Fulvia ha fari rettangolari e linea più morbida',
            'specs': <String, dynamic>{},
            'fun_fact': '',
            'market_value_range': '',
            'timeline': [],
          },
        ],
      };

      // Simulate what GeminiService does internally
      final List<CarIdentification> results;
      if (responseJson.containsKey('matches') &&
          responseJson['matches'] is List) {
        final matchesList = responseJson['matches'] as List;
        results = matchesList
            .whereType<Map<String, dynamic>>()
            .map((m) => CarIdentification.fromJson(m))
            .toList();
      } else {
        results = [CarIdentification.fromJson(responseJson)];
      }

      expect(results.length, 3);

      // Primary match
      expect(results[0].brand, 'Alfa Romeo');
      expect(results[0].model, 'GT 1300 Junior');
      expect(results[0].confidence, 0.85);
      expect(results[0].keyDifference, '');
      expect(results[0].engineCode, 'AR 00526');

      // First alternative
      expect(results[1].brand, 'Alfa Romeo');
      expect(results[1].model, 'Giulia Sprint GT');
      expect(results[1].confidence, 0.10);
      expect(results[1].keyDifference,
          'La Sprint GT ha la calandra più stretta e paraurti diversi');

      // Second alternative
      expect(results[2].brand, 'Lancia');
      expect(results[2].model, 'Fulvia Coupé');
      expect(results[2].confidence, 0.05);
      expect(results[2].keyDifference,
          'La Fulvia ha fari rettangolari e linea più morbida');
    });

    test('parses single-object response (backward compatibility)', () {
      final responseJson = {
        'brand': 'Ferrari',
        'model': '250 GTO',
        'year_estimate': '1962-1964',
        'body_type': 'Coupé',
        'color': 'Rosso Corsa',
        'confidence': 0.95,
        'details': 'Auto iconica.',
        'distinguishing_features': ['prese d\'aria'],
        'specs': {
          'engine_code': 'Tipo 168/62',
          'displacement': '2953 cc',
          'power': '300 CV',
        },
        'fun_fact': 'Solo 36 esemplari prodotti.',
        'market_value_range': '€50.000.000+',
        'timeline': ['1962: Prima corsa'],
      };

      // Simulate backward compat parsing
      final List<CarIdentification> results;
      if (responseJson.containsKey('matches') &&
          responseJson['matches'] is List) {
        final matchesList = responseJson['matches'] as List;
        results = matchesList
            .whereType<Map<String, dynamic>>()
            .map((m) => CarIdentification.fromJson(m))
            .toList();
      } else {
        results = [CarIdentification.fromJson(responseJson)];
      }

      expect(results.length, 1);
      expect(results[0].brand, 'Ferrari');
      expect(results[0].model, '250 GTO');
      expect(results[0].confidence, 0.95);
      expect(results[0].keyDifference, '');
    });

    test('single match in matches array works correctly', () {
      final responseJson = {
        'matches': [
          {
            'brand': 'Porsche',
            'model': '911 Carrera RS',
            'year_estimate': '1973',
            'body_type': 'Coupé',
            'color': 'Bianco/Verde',
            'confidence': 0.95,
            'details': 'La RS è la versione alleggerita.',
            'distinguishing_features': ['ala posteriore'],
            'key_difference': '',
            'specs': <String, dynamic>{},
            'fun_fact': '',
            'market_value_range': '',
            'timeline': [],
          },
        ],
      };

      final matchesList = responseJson['matches'] as List;
      final results = matchesList
          .whereType<Map<String, dynamic>>()
          .map((m) => CarIdentification.fromJson(m))
          .toList();

      expect(results.length, 1);
      expect(results[0].brand, 'Porsche');
      expect(results[0].confidence, 0.95);
    });

    test('confidence values are valid (clamped between 0 and 1)', () {
      final responseJson = {
        'matches': [
          {
            'brand': 'Test',
            'model': 'Over',
            'year_estimate': '2000',
            'body_type': 'Sedan',
            'color': 'Nero',
            'confidence': 1.5,
            'details': '',
            'distinguishing_features': [],
            'key_difference': '',
            'specs': <String, dynamic>{},
          },
          {
            'brand': 'Test',
            'model': 'Under',
            'year_estimate': '2000',
            'body_type': 'Sedan',
            'color': 'Nero',
            'confidence': -0.5,
            'details': '',
            'distinguishing_features': [],
            'key_difference': '',
            'specs': <String, dynamic>{},
          },
        ],
      };

      final matchesList = responseJson['matches'] as List;
      final results = matchesList
          .whereType<Map<String, dynamic>>()
          .map((m) => CarIdentification.fromJson(m))
          .toList();

      expect(results[0].confidence, 1.0); // clamped to max
      expect(results[1].confidence, 0.0); // clamped to min
    });

    test('confidence as string is parsed correctly', () {
      final json = {
        'brand': 'Fiat',
        'model': '124 Spider',
        'year_estimate': '1966',
        'body_type': 'Spider',
        'color': 'Rosso',
        'confidence': '0.75',
        'details': '',
        'distinguishing_features': [],
        'specs': <String, dynamic>{},
      };

      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 0.75);
    });

    test('confidence as integer is parsed correctly', () {
      final json = {
        'brand': 'Fiat',
        'model': '124 Spider',
        'year_estimate': '1966',
        'body_type': 'Spider',
        'color': 'Rosso',
        'confidence': 1,
        'details': '',
        'distinguishing_features': [],
        'specs': <String, dynamic>{},
      };

      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 1.0);
    });
  });
}
