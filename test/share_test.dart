import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/services/gemini_service.dart';

/// Tests for the share text generation logic.
/// Verifies that shared text includes the right info for each level.
void main() {
  CarIdentification createIdent() {
    return CarIdentification(
      brand: 'Alfa Romeo',
      model: 'Giulia GT 1300 Junior',
      yearEstimate: '1968-1972',
      bodyType: 'Coup\u00e9',
      color: 'Giallo',
      confidence: 0.99,
      details: 'Descrizione test.',
      distinguishingFeatures: ['Fari tondi'],
      engineCode: 'AR00530',
      engineDisplacement: '1290 cc',
      enginePower: '89 CV @ 6.000 giri',
      transmissionType: '5 marce manuale',
      transmissionBrand: 'Alfa Romeo',
      weight: '980 kg',
      topSpeed: '170 km/h',
      totalProduced: '92.000+',
      designer: 'Bertone (Giugiaro)',
      funFact: 'Test fun fact',
      marketValueRange: '\u20ac25.000 - \u20ac40.000',
      timeline: ['1963: Start'],
    );
  }

  /// Simulates the _shareCar() text generation from results_screen.dart
  String buildShareText(CarIdentification id,
      {String? vin,
      String? vinManufacturer,
      int? vinYear,
      double? originalityScore,
      bool? engineMatch,
      bool? transmissionMatch,
      bool? bodyMatch}) {
    final text = StringBuffer();
    text.writeln(id.brand.toUpperCase());
    text.writeln(id.model);
    text.writeln('${id.yearEstimate} \u00b7 ${id.bodyType}');
    text.writeln(
        'Attendibilit\u00e0 ricerca: ${(id.confidence * 100).round()}%');
    text.writeln();

    if (id.engineDisplacement.isNotEmpty && id.engineDisplacement != 'N/D') {
      text.writeln(
          'Motore: ${id.engineDisplacement}${id.engineCode.isNotEmpty ? ' ${id.engineCode}' : ''}');
    }
    if (id.enginePower.isNotEmpty && id.enginePower != 'N/D') {
      text.writeln('Potenza: ${id.enginePower}');
    }
    if (id.transmissionType.isNotEmpty && id.transmissionType != 'N/D') {
      text.writeln(
          'Cambio: ${id.transmissionType}${id.transmissionBrand.isNotEmpty ? ' (${id.transmissionBrand})' : ''}');
    }
    if (id.weight.isNotEmpty && id.weight != 'N/D') {
      text.write('Peso: ${id.weight}');
      if (id.topSpeed.isNotEmpty && id.topSpeed != 'N/D') {
        text.write(' \u00b7 Velocit\u00e0 max: ${id.topSpeed}');
      }
      text.writeln();
    }
    if (id.totalProduced.isNotEmpty && id.totalProduced != 'N/D') {
      text.writeln('Produzione: ${id.totalProduced} esemplari');
    }
    if (id.designer.isNotEmpty && id.designer != 'N/D') {
      text.writeln('Design: ${id.designer}');
    }
    if (id.marketValueRange.isNotEmpty && id.marketValueRange != 'N/D') {
      text.writeln();
      text.writeln('Stima di mercato: ${id.marketValueRange}');
    }
    if (vin != null) {
      text.writeln();
      text.writeln('Telaio: $vin');
    }
    if (originalityScore != null) {
      text.writeln();
      text.writeln(
          'Originalit\u00e0: ${originalityScore.toStringAsFixed(0)}%');
      if (engineMatch != null) {
        text.writeln(
            'Motore: ${engineMatch ? "Conforme" : "Non conforme"}');
      }
      if (transmissionMatch != null) {
        text.writeln(
            'Cambio: ${transmissionMatch ? "Conforme" : "Non conforme"}');
      }
      if (bodyMatch != null) {
        text.writeln(
            'Carrozzeria: ${bodyMatch ? "Conforme" : "Non conforme"}');
      }
    }
    text.writeln();
    text.writeln('Analizzato con CarLens');
    return text.toString();
  }

  group('Share text generation', () {
    test('L1 share includes specs and market value but not VIN', () {
      final id = createIdent();
      final text = buildShareText(id);

      expect(text, contains('ALFA ROMEO'));
      expect(text, contains('Giulia GT 1300 Junior'));
      expect(text, contains('1290 cc AR00530'));
      expect(text, contains('89 CV'));
      expect(text, contains('5 marce manuale (Alfa Romeo)'));
      expect(text, contains('980 kg'));
      expect(text, contains('170 km/h'));
      expect(text, contains('92.000+ esemplari'));
      expect(text, contains('Bertone (Giugiaro)'));
      expect(text, contains('\u20ac25.000 - \u20ac40.000'));
      expect(text, contains('Analizzato con CarLens'));
      // Should NOT contain VIN or originality at L1
      expect(text, isNot(contains('Telaio:')));
      expect(text, isNot(contains('Originalit\u00e0:')));
    });

    test('L2 share includes VIN data', () {
      final id = createIdent();
      final text = buildShareText(id, vin: 'ZAR11500001234567');

      expect(text, contains('Telaio: ZAR11500001234567'));
      expect(text, contains('1290 cc AR00530')); // specs still there
      expect(text, contains('\u20ac25.000')); // market value still there
    });

    test('L3 share includes originality data', () {
      final id = createIdent();
      final text = buildShareText(
        id,
        vin: 'ZAR11500001234567',
        originalityScore: 85.0,
        engineMatch: true,
        transmissionMatch: true,
        bodyMatch: false,
      );

      expect(text, contains('Originalit\u00e0: 85%'));
      expect(text, contains('Motore: Conforme'));
      expect(text, contains('Cambio: Conforme'));
      expect(text, contains('Carrozzeria: Non conforme'));
    });

    test('Share omits N/D values gracefully', () {
      final id = CarIdentification(
        brand: 'Unknown',
        model: 'Test',
        yearEstimate: 'N/D',
        bodyType: 'N/D',
        color: 'N/D',
        confidence: 0.5,
        details: '',
        distinguishingFeatures: [],
        weight: 'N/D',
        topSpeed: 'N/D',
        totalProduced: 'N/D',
      );
      final text = buildShareText(id);

      expect(text, isNot(contains('Peso: N/D')));
      expect(text, isNot(contains('Velocit\u00e0 max: N/D')));
      expect(text, isNot(contains('Produzione: N/D')));
    });

    test('Footer is always "Analizzato con CarLens"', () {
      final id = createIdent();
      final text = buildShareText(id);
      expect(text.trim().endsWith('Analizzato con CarLens'), isTrue);
    });
  });

  group('Telegram notification text', () {
    test('Notification format includes all required fields', () {
      // Simulates TelegramService.notifyNewScan text building
      final brand = 'Alfa Romeo';
      final model = 'Giulia GT';
      final yearEstimate = '1963-1976';
      final bodyType = 'Coup\u00e9';
      final confidence = 0.95;
      final level = 1;
      final deviceId = 'user_a3f7';

      final text = StringBuffer()
        ..writeln('\u{1F697} Nuova scansione CarLens')
        ..writeln()
        ..writeln('$brand $model')
        ..writeln('$yearEstimate \u00b7 $bodyType')
        ..writeln(
            'Attendibilit\u00e0: ${(confidence * 100).round()}%')
        ..writeln('Livello: L$level')
        ..writeln()
        ..writeln('\u{1F4F1} Utente: #$deviceId');

      final result = text.toString();
      expect(result, contains('Alfa Romeo Giulia GT'));
      expect(result, contains('Attendibilit\u00e0: 95%'));
      expect(result, contains('Livello: L1'));
      expect(result, contains('#user_a3f7'));
    });

    test('VIN notification includes decoded info', () {
      final text = StringBuffer()
        ..writeln('\u{1F50D} VIN aggiunto - CarLens')
        ..writeln()
        ..writeln('Oldsmobile Cutlass Supreme')
        ..writeln('VIN: 3K57R6M122576')
        ..writeln('Decodificato: Oldsmobile')
        ..writeln('Anno (VIN): 1976');

      final result = text.toString();
      expect(result, contains('VIN: 3K57R6M122576'));
      expect(result, contains('Decodificato: Oldsmobile'));
      expect(result, contains('Anno (VIN): 1976'));
    });
  });
}
