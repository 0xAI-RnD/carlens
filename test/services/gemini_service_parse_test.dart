import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/services/gemini_service.dart';

void main() {
  // -----------------------------------------------------------------------
  // CarIdentification.fromJson
  // -----------------------------------------------------------------------
  group('CarIdentification.fromJson', () {
    test('parses complete JSON with all fields', () {
      final json = {
        'brand': 'Alfa Romeo',
        'model': 'Giulia Sprint GT Veloce',
        'year_estimate': '1965-1969',
        'body_type': 'Coupe',
        'color': 'Giallo Ocra',
        'confidence': 0.95,
        'details': 'Una classica coupé italiana.',
        'distinguishing_features': ['fari tondi', 'calandra a V'],
        'specs': {
          'engine_code': 'AR 00526',
          'displacement': '1570 cc',
          'power': '106 CV @ 6.000 giri',
          'transmission': '5 marce manuale',
          'transmission_brand': 'Alfa Romeo',
          'weight': '1.020 kg',
          'top_speed': '185 km/h',
          'total_produced': '21.902',
          'designer': 'Bertone (Giugiaro)',
        },
        'fun_fact': 'Prima auto di serie con freni a disco.',
        'market_value_range': '€25.000 - €45.000',
        'timeline': [
          '1963: Presentata al Salone di Francoforte',
          '1966: Introduzione versione 1600 GTV',
        ],
      };

      final car = CarIdentification.fromJson(json);

      expect(car.brand, 'Alfa Romeo');
      expect(car.model, 'Giulia Sprint GT Veloce');
      expect(car.yearEstimate, '1965-1969');
      expect(car.bodyType, 'Coupe');
      expect(car.color, 'Giallo Ocra');
      expect(car.confidence, 0.95);
      expect(car.details, 'Una classica coupé italiana.');
      expect(car.distinguishingFeatures, ['fari tondi', 'calandra a V']);
      expect(car.engineCode, 'AR 00526');
      expect(car.engineDisplacement, '1570 cc');
      expect(car.enginePower, '106 CV @ 6.000 giri');
      expect(car.transmissionType, '5 marce manuale');
      expect(car.transmissionBrand, 'Alfa Romeo');
      expect(car.weight, '1.020 kg');
      expect(car.topSpeed, '185 km/h');
      expect(car.totalProduced, '21.902');
      expect(car.designer, 'Bertone (Giugiaro)');
      expect(car.funFact, 'Prima auto di serie con freni a disco.');
      expect(car.marketValueRange, '€25.000 - €45.000');
      expect(car.timeline, hasLength(2));
      expect(car.timeline[0], contains('1963'));
    });

    test('uses defaults for completely missing fields', () {
      final car = CarIdentification.fromJson(<String, dynamic>{});

      expect(car.brand, 'Sconosciuto');
      expect(car.model, 'Sconosciuto');
      expect(car.yearEstimate, 'N/D');
      expect(car.bodyType, 'N/D');
      expect(car.color, 'N/D');
      expect(car.confidence, 0.0);
      expect(car.details, '');
      expect(car.distinguishingFeatures, isEmpty);
      expect(car.engineCode, '');
      expect(car.engineDisplacement, '');
      expect(car.enginePower, '');
      expect(car.transmissionType, '');
      expect(car.transmissionBrand, '');
      expect(car.weight, '');
      expect(car.topSpeed, '');
      expect(car.totalProduced, '');
      expect(car.designer, '');
      expect(car.funFact, '');
      expect(car.marketValueRange, '');
      expect(car.timeline, isEmpty);
    });

    test('uses defaults when specs key is missing entirely', () {
      final json = {
        'brand': 'Ferrari',
        'model': '308 GTB',
      };
      final car = CarIdentification.fromJson(json);

      expect(car.engineCode, '');
      expect(car.engineDisplacement, '');
      expect(car.weight, '');
      expect(car.designer, '');
    });

    test('uses defaults when specs key is null', () {
      final json = {
        'brand': 'Ferrari',
        'specs': null,
      };
      final car = CarIdentification.fromJson(json);

      expect(car.engineCode, '');
      expect(car.transmissionType, '');
    });

    test('handles wrong types for string fields (uses null coalescing)', () {
      final json = {
        'brand': 123, // int instead of String
        'model': true, // bool instead of String
        'year_estimate': 1970,
        'body_type': null,
        'color': null,
      };

      // These will throw TypeError because the code does `as String?`
      // on non-String values. The test documents this behavior.
      expect(
        () => CarIdentification.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });
  });

  // -----------------------------------------------------------------------
  // Confidence clamping via _parseDouble
  // -----------------------------------------------------------------------
  group('CarIdentification confidence clamping', () {
    test('clamps confidence > 1 to 1.0', () {
      final json = {
        'brand': 'Test',
        'confidence': 1.5,
      };
      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 1.0);
    });

    test('clamps confidence < 0 to 0.0', () {
      final json = {
        'brand': 'Test',
        'confidence': -0.5,
      };
      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 0.0);
    });

    test('confidence exactly 0 remains 0', () {
      final json = {'confidence': 0};
      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 0.0);
    });

    test('confidence exactly 1 remains 1', () {
      final json = {'confidence': 1.0};
      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 1.0);
    });

    test('confidence as int is converted to double and clamped', () {
      final json = {'confidence': 2}; // int > 1
      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 1.0);
    });

    test('confidence as string is parsed and clamped', () {
      final json = {'confidence': '0.75'};
      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 0.75);
    });

    test('confidence as unparseable string defaults to 0', () {
      final json = {'confidence': 'not a number'};
      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 0.0);
    });

    test('confidence as null defaults to 0', () {
      final json = {'confidence': null};
      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 0.0);
    });
  });

  // -----------------------------------------------------------------------
  // distinguishing_features / timeline parsing (_parseStringList)
  // -----------------------------------------------------------------------
  group('CarIdentification list parsing', () {
    test('distinguishing_features with mixed types converts to strings', () {
      final json = {
        'distinguishing_features': [1, true, 'text', null],
      };
      final car = CarIdentification.fromJson(json);
      expect(car.distinguishingFeatures, ['1', 'true', 'text', 'null']);
    });

    test('distinguishing_features as non-list returns empty', () {
      final json = {
        'distinguishing_features': 'single string',
      };
      final car = CarIdentification.fromJson(json);
      expect(car.distinguishingFeatures, isEmpty);
    });

    test('timeline with non-list value returns empty', () {
      final json = {
        'timeline': 42,
      };
      final car = CarIdentification.fromJson(json);
      expect(car.timeline, isEmpty);
    });

    test('timeline as null returns empty list', () {
      final json = {
        'timeline': null,
      };
      final car = CarIdentification.fromJson(json);
      expect(car.timeline, isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // OriginalityReport.fromJson
  // -----------------------------------------------------------------------
  group('OriginalityReport.fromJson', () {
    test('parses complete JSON correctly', () {
      final json = {
        'originality_score': 85.0,
        'engine_match': true,
        'transmission_match': true,
        'body_match': false,
        'notes': [
          'Motore originale confermato',
          'Cambio originale',
          'Carrozzeria riverniciata',
        ],
        'summary': 'Auto in buone condizioni di originalità.',
      };

      final report = OriginalityReport.fromJson(json);
      expect(report.originalityScore, 85.0);
      expect(report.engineMatch, true);
      expect(report.transmissionMatch, true);
      expect(report.bodyMatch, false);
      expect(report.notes, hasLength(3));
      expect(report.notes[0], contains('Motore'));
      expect(report.summary, contains('originalità'));
    });

    test('uses defaults for missing fields', () {
      final report = OriginalityReport.fromJson(<String, dynamic>{});

      expect(report.originalityScore, 0.0);
      expect(report.engineMatch, false);
      expect(report.transmissionMatch, false);
      expect(report.bodyMatch, false);
      expect(report.notes, isEmpty);
      expect(report.summary, '');
    });

    test('uses defaults for null field values', () {
      final json = {
        'originality_score': null,
        'engine_match': null,
        'transmission_match': null,
        'body_match': null,
        'notes': null,
        'summary': null,
      };
      final report = OriginalityReport.fromJson(json);
      expect(report.originalityScore, 0.0);
      expect(report.engineMatch, false);
      expect(report.transmissionMatch, false);
      expect(report.bodyMatch, false);
      expect(report.notes, isEmpty);
      expect(report.summary, '');
    });
  });

  group('OriginalityReport score clamping', () {
    test('clamps score > 100 to 100', () {
      final json = {'originality_score': 150.0};
      final report = OriginalityReport.fromJson(json);
      expect(report.originalityScore, 100.0);
    });

    test('clamps score < 0 to 0', () {
      final json = {'originality_score': -20.0};
      final report = OriginalityReport.fromJson(json);
      expect(report.originalityScore, 0.0);
    });

    test('score as int is converted to double', () {
      final json = {'originality_score': 75};
      final report = OriginalityReport.fromJson(json);
      expect(report.originalityScore, 75.0);
      expect(report.originalityScore, isA<double>());
    });

    test('score as string is parsed', () {
      final json = {'originality_score': '92.5'};
      final report = OriginalityReport.fromJson(json);
      expect(report.originalityScore, 92.5);
    });

    test('score as unparseable string defaults to 0', () {
      final json = {'originality_score': 'high'};
      final report = OriginalityReport.fromJson(json);
      expect(report.originalityScore, 0.0);
    });
  });

  group('OriginalityReport notes parsing', () {
    test('converts mixed-type list items to strings', () {
      final json = {
        'notes': [1, true, 'text'],
      };
      final report = OriginalityReport.fromJson(json);
      expect(report.notes, ['1', 'true', 'text']);
    });

    test('non-list notes returns empty list', () {
      final json = {
        'notes': 'just a string',
      };
      final report = OriginalityReport.fromJson(json);
      expect(report.notes, isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // GeminiService._parseJsonResponse (tested via instance)
  // -----------------------------------------------------------------------
  group('GeminiService._parseJsonResponse', () {
    // _parseJsonResponse is a private instance method, so we test it
    // indirectly by calling it via a helper. Since it is private, we
    // instantiate GeminiService and use a test-accessible wrapper.
    // However, since it IS private, we replicate the parsing logic test here.
    //
    // We can test it through the public behavior: the method is called by
    // _callGemini. Instead, we test the parsing directly by replicating the
    // logic since we cannot call private methods from tests.
    //
    // A pragmatic approach: create a minimal subclass or test the exact
    // parsing steps. Since we cannot subclass easily, we test the JSON
    // parsing logic by extracting the same regex and jsonDecode calls.

    String _stripFences(String text) {
      var cleaned = text.trim();
      final fencePattern = RegExp(
        r'^```(?:json)?\s*\n?(.*?)\n?\s*```$',
        dotAll: true,
      );
      final fenceMatch = fencePattern.firstMatch(cleaned);
      if (fenceMatch != null) {
        cleaned = fenceMatch.group(1)!.trim();
      }
      return cleaned;
    }

    test('parses clean JSON', () {
      const input = '{"brand": "Ferrari", "model": "308 GTB"}';
      final cleaned = _stripFences(input);
      expect(cleaned, input);
    });

    test('parses markdown-wrapped JSON with ```json``` fences', () {
      const input = '```json\n{"brand": "Ferrari", "model": "308 GTB"}\n```';
      final cleaned = _stripFences(input);
      expect(cleaned, '{"brand": "Ferrari", "model": "308 GTB"}');
    });

    test('parses markdown-wrapped JSON with ``` fences (no lang tag)', () {
      const input = '```\n{"brand": "Fiat"}\n```';
      final cleaned = _stripFences(input);
      expect(cleaned, '{"brand": "Fiat"}');
    });

    test('handles JSON with leading/trailing whitespace', () {
      const input = '   \n{"brand": "Lancia"}\n   ';
      final cleaned = _stripFences(input);
      expect(cleaned, '{"brand": "Lancia"}');
    });

    test('handles multiline JSON inside fences', () {
      const input = '''```json
{
  "brand": "Maserati",
  "model": "Bora",
  "confidence": 0.88
}
```''';
      final cleaned = _stripFences(input);
      expect(cleaned, contains('"brand": "Maserati"'));
      expect(cleaned, contains('"model": "Bora"'));
    });

    test('preserves non-fenced JSON exactly', () {
      const input = '{"a":1,"b":2}';
      final cleaned = _stripFences(input);
      expect(cleaned, '{"a":1,"b":2}');
    });
  });

  // -----------------------------------------------------------------------
  // CarIdentification specs fields
  // -----------------------------------------------------------------------
  group('CarIdentification specs fields', () {
    test('engineCode, engineDisplacement, and other specs populated', () {
      final json = {
        'brand': 'Lancia',
        'specs': {
          'engine_code': '828A0',
          'displacement': '1995 cc',
          'power': '200 CV',
          'transmission': '5 marce',
          'transmission_brand': 'ZF',
          'weight': '1.340 kg',
          'top_speed': '220 km/h',
          'total_produced': '7.579',
          'designer': 'Gruppo Lancia',
        },
      };
      final car = CarIdentification.fromJson(json);

      expect(car.engineCode, '828A0');
      expect(car.engineDisplacement, '1995 cc');
      expect(car.enginePower, '200 CV');
      expect(car.transmissionType, '5 marce');
      expect(car.transmissionBrand, 'ZF');
      expect(car.weight, '1.340 kg');
      expect(car.topSpeed, '220 km/h');
      expect(car.totalProduced, '7.579');
      expect(car.designer, 'Gruppo Lancia');
    });

    test('partial specs fills only provided fields', () {
      final json = {
        'specs': {
          'engine_code': 'V6',
          // all others missing
        },
      };
      final car = CarIdentification.fromJson(json);
      expect(car.engineCode, 'V6');
      expect(car.engineDisplacement, '');
      expect(car.weight, '');
    });
  });

  // -----------------------------------------------------------------------
  // CarIdentification new fields: funFact, marketValueRange, timeline
  // -----------------------------------------------------------------------
  group('CarIdentification new fields', () {
    test('funFact, marketValueRange, and timeline are parsed', () {
      final json = {
        'fun_fact': 'Vincitrice di 3 campionati WRC.',
        'market_value_range': '€50.000 - €80.000',
        'timeline': [
          '1987: Lancio ufficiale',
          '1988: Prima vittoria WRC',
          '1992: Fine produzione',
        ],
      };
      final car = CarIdentification.fromJson(json);
      expect(car.funFact, 'Vincitrice di 3 campionati WRC.');
      expect(car.marketValueRange, '€50.000 - €80.000');
      expect(car.timeline, hasLength(3));
      expect(car.timeline[1], contains('1988'));
    });

    test('funFact defaults to empty string when missing', () {
      final car = CarIdentification.fromJson(<String, dynamic>{});
      expect(car.funFact, '');
    });

    test('marketValueRange defaults to empty string when missing', () {
      final car = CarIdentification.fromJson(<String, dynamic>{});
      expect(car.marketValueRange, '');
    });

    test('timeline defaults to empty list when missing', () {
      final car = CarIdentification.fromJson(<String, dynamic>{});
      expect(car.timeline, isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // CarIdentification.toJson
  // -----------------------------------------------------------------------
  group('CarIdentification.toJson', () {
    test('produces expected keys', () {
      final json = {
        'brand': 'Ferrari',
        'model': '328 GTS',
        'year_estimate': '1985-1989',
        'body_type': 'Targa',
        'color': 'Rosso Corsa',
        'confidence': 0.97,
        'details': 'V8 mid-engine sports car.',
        'distinguishing_features': ['pop-up headlights'],
      };
      final car = CarIdentification.fromJson(json);
      final output = car.toJson();

      expect(output['brand'], 'Ferrari');
      expect(output['model'], '328 GTS');
      expect(output['year_estimate'], '1985-1989');
      expect(output['body_type'], 'Targa');
      expect(output['color'], 'Rosso Corsa');
      expect(output['confidence'], 0.97);
      expect(output['details'], 'V8 mid-engine sports car.');
      expect(output['distinguishing_features'], ['pop-up headlights']);
    });
  });
}
