import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/services/gemini_service.dart';

void main() {
  group('CarIdentification.fromJson', () {
    test('complete data populates all fields', () {
      final json = {
        'brand': 'Alfa Romeo',
        'model': 'Giulia Sprint GT',
        'year_estimate': '1965-1969',
        'body_type': 'Coupe',
        'color': 'Rosso',
        'confidence': 0.95,
        'details': 'Iconica berlina sportiva italiana.',
        'distinguishing_features': ['fari tondi', 'calandra a V'],
        'specs': {
          'engine_code': 'AR 00526',
          'displacement': '1570 cc',
          'power': '106 CV',
          'transmission': '5 marce manuale',
          'transmission_brand': 'Alfa Romeo',
          'weight': '1020 kg',
          'top_speed': '185 km/h',
          'total_produced': '21902',
          'designer': 'Bertone (Giugiaro)',
        },
        'fun_fact': 'Giugiaro aveva solo 23 anni quando la disegno.',
        'market_value_range': '25000-45000',
        'timeline': ['1963: Debutto', '1976: Fine produzione'],
      };

      final car = CarIdentification.fromJson(json);

      expect(car.brand, 'Alfa Romeo');
      expect(car.model, 'Giulia Sprint GT');
      expect(car.yearEstimate, '1965-1969');
      expect(car.bodyType, 'Coupe');
      expect(car.color, 'Rosso');
      expect(car.confidence, 0.95);
      expect(car.details, 'Iconica berlina sportiva italiana.');
      expect(car.distinguishingFeatures, ['fari tondi', 'calandra a V']);
      expect(car.engineCode, 'AR 00526');
      expect(car.engineDisplacement, '1570 cc');
      expect(car.enginePower, '106 CV');
      expect(car.transmissionType, '5 marce manuale');
      expect(car.transmissionBrand, 'Alfa Romeo');
      expect(car.weight, '1020 kg');
      expect(car.topSpeed, '185 km/h');
      expect(car.totalProduced, '21902');
      expect(car.designer, 'Bertone (Giugiaro)');
      expect(car.funFact, 'Giugiaro aveva solo 23 anni quando la disegno.');
      expect(car.marketValueRange, '25000-45000');
      expect(car.timeline, ['1963: Debutto', '1976: Fine produzione']);
    });

    test('missing specs defaults to empty strings', () {
      final json = {
        'brand': 'Fiat',
        'model': '500',
        'year_estimate': '1957',
        'body_type': 'Sedan',
        'color': 'Bianco',
        'confidence': 0.8,
        'details': 'Utilitaria iconica.',
        'distinguishing_features': [],
        // no 'specs' key
      };

      final car = CarIdentification.fromJson(json);

      expect(car.engineCode, '');
      expect(car.engineDisplacement, '');
      expect(car.enginePower, '');
      expect(car.transmissionType, '');
      expect(car.transmissionBrand, '');
      expect(car.weight, '');
      expect(car.topSpeed, '');
      expect(car.totalProduced, '');
      expect(car.designer, '');
    });

    test('null fun_fact defaults to empty string', () {
      final json = {
        'brand': 'Fiat',
        'model': '124',
        'year_estimate': '1970',
        'body_type': 'Spider',
        'color': 'Rosso',
        'confidence': 0.7,
        'details': '',
        'fun_fact': null,
      };

      final car = CarIdentification.fromJson(json);
      expect(car.funFact, '');
    });

    test('empty timeline list results in empty list', () {
      final json = {
        'brand': 'Lancia',
        'model': 'Fulvia',
        'year_estimate': '1965',
        'body_type': 'Coupe',
        'color': 'Blu',
        'confidence': 0.85,
        'details': '',
        'timeline': [],
      };

      final car = CarIdentification.fromJson(json);
      expect(car.timeline, isEmpty);
    });

    test('market_value_range parsed correctly', () {
      final json = {
        'brand': 'Ferrari',
        'model': '308 GTB',
        'year_estimate': '1980',
        'body_type': 'Berlinetta',
        'color': 'Rosso Corsa',
        'confidence': 0.99,
        'details': '',
        'market_value_range': '80000-120000',
      };

      final car = CarIdentification.fromJson(json);
      expect(car.marketValueRange, '80000-120000');
    });

    test('confidence as string "0.95" parsed to double 0.95', () {
      final json = {
        'brand': 'Test',
        'model': 'Model',
        'year_estimate': '2000',
        'body_type': 'Sedan',
        'color': 'Black',
        'confidence': '0.95',
        'details': '',
      };

      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 0.95);
    });

    test('confidence as int 1 parsed to 1.0', () {
      final json = {
        'brand': 'Test',
        'model': 'Model',
        'year_estimate': '2000',
        'body_type': 'Sedan',
        'color': 'Black',
        'confidence': 1,
        'details': '',
      };

      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 1.0);
    });

    test('confidence > 1 clamped to 1.0', () {
      final json = {
        'brand': 'Test',
        'model': 'Model',
        'year_estimate': '2000',
        'body_type': 'Sedan',
        'color': 'Black',
        'confidence': 1.5,
        'details': '',
      };

      final car = CarIdentification.fromJson(json);
      expect(car.confidence, 1.0);
    });
  });

  group('OriginalityReport.fromJson', () {
    test('complete data populates all fields', () {
      final json = {
        'originality_score': 85.0,
        'engine_match': true,
        'transmission_match': true,
        'body_match': false,
        'notes': [
          'Motore corrisponde al tipo originale',
          'Carrozzeria presenta modifiche',
        ],
        'summary': 'Auto in buone condizioni di originalita.',
      };

      final report = OriginalityReport.fromJson(json);

      expect(report.originalityScore, 85.0);
      expect(report.engineMatch, isTrue);
      expect(report.transmissionMatch, isTrue);
      expect(report.bodyMatch, isFalse);
      expect(report.notes, hasLength(2));
      expect(report.summary, 'Auto in buone condizioni di originalita.');
    });

    test('missing fields default to sensible values', () {
      final json = <String, dynamic>{};

      final report = OriginalityReport.fromJson(json);

      expect(report.originalityScore, 0.0);
      expect(report.engineMatch, isFalse);
      expect(report.transmissionMatch, isFalse);
      expect(report.bodyMatch, isFalse);
      expect(report.notes, isEmpty);
      expect(report.summary, '');
    });

    test('notes containing "corrisponde" identifiable for green badge', () {
      final json = {
        'originality_score': 90.0,
        'engine_match': true,
        'transmission_match': true,
        'body_match': true,
        'notes': [
          'Il motore corrisponde al tipo originale previsto',
          'Il cambio corrisponde alla specifica di fabbrica',
        ],
        'summary': 'Ottima originalita.',
      };

      final report = OriginalityReport.fromJson(json);

      final greenNotes =
          report.notes.where((n) => n.contains('corrisponde')).toList();
      expect(greenNotes, isNotEmpty);
      expect(greenNotes.length, 2);
    });

    test('notes containing "diverso" identifiable for red badge', () {
      final json = {
        'originality_score': 50.0,
        'engine_match': false,
        'transmission_match': false,
        'body_match': true,
        'notes': [
          'Il motore e diverso da quello originale',
          'Il cambio e diverso dalla specifica di fabbrica',
        ],
        'summary': 'Numerose modifiche rilevate.',
      };

      final report = OriginalityReport.fromJson(json);

      final redNotes =
          report.notes.where((n) => n.contains('diverso')).toList();
      expect(redNotes, isNotEmpty);
      expect(redNotes.length, 2);
    });
  });
}
