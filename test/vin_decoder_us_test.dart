import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/utils/vin_decoder.dart';

void main() {
  group('Pre-1981 US GM VIN decoding', () {
    test('decodes GM VIN "3K57R6M122576" as Oldsmobile Cutlass Supreme 1976 Lansing MI', () {
      final result = VinDecoder.decode('3K57R6M122576');

      expect(result.isValid, isTrue);
      expect(result.isPreStandard, isTrue);
      expect(result.manufacturer, 'Oldsmobile');
      expect(result.modelIndicator, 'K57');
      expect(result.year, 1976);
      expect(result.assemblyPlant, 'Lansing, MI');
      expect(result.country, 'United States');
      expect(result.serialNumber, '122576');
    });

    test('decodes GM VIN with division 1 as Chevrolet', () {
      final result = VinDecoder.decode('1D37L5F100001');

      expect(result.isValid, isTrue);
      expect(result.isPreStandard, isTrue);
      expect(result.manufacturer, 'Chevrolet');
    });

    test('decodes GM VIN with division 2 as Pontiac', () {
      final result = VinDecoder.decode('2F87R5P200001');

      expect(result.isValid, isTrue);
      expect(result.isPreStandard, isTrue);
      expect(result.manufacturer, 'Pontiac');
    });

    test('decodes GM VIN with division 4 as Buick', () {
      final result = VinDecoder.decode('4J37H7K300001');

      expect(result.isValid, isTrue);
      expect(result.isPreStandard, isTrue);
      expect(result.manufacturer, 'Buick');
    });

    test('decodes GM VIN with division 6 as Cadillac', () {
      final result = VinDecoder.decode('6D47S8D400001');

      expect(result.isValid, isTrue);
      expect(result.isPreStandard, isTrue);
      expect(result.manufacturer, 'Cadillac');
    });

    test('decodes GM VIN with year code A as 1980', () {
      final result = VinDecoder.decode('3K57RAM122576');

      expect(result.isValid, isTrue);
      expect(result.isPreStandard, isTrue);
      expect(result.year, 1980);
    });

    test('decodes GM VIN with year code 0 as 1970', () {
      final result = VinDecoder.decode('1D37L0F100001');

      expect(result.isValid, isTrue);
      expect(result.isPreStandard, isTrue);
      expect(result.year, 1970);
    });
  });

  group('Standard 17-char US VIN decoding', () {
    test('decodes "1G3HN57Y2T4100001" as Oldsmobile', () {
      final result = VinDecoder.decode('1G3HN57Y2T4100001');

      expect(result.manufacturer, 'Oldsmobile');
      expect(result.country, 'United States');
      expect(result.isPreStandard, isFalse);
    });

    test('decodes VIN with BMW WMI "WBA" as BMW', () {
      final result = VinDecoder.decode('WBAPH5C55BA000001');

      expect(result.manufacturer, 'BMW');
      expect(result.country, 'Germany');
      expect(result.isPreStandard, isFalse);
    });

    test('decodes VIN with Mercedes WMI "WDB" as Mercedes-Benz', () {
      final result = VinDecoder.decode('WDBRF61J21F000001');

      expect(result.manufacturer, 'Mercedes-Benz');
      expect(result.country, 'Germany');
      expect(result.isPreStandard, isFalse);
    });

    test('decodes VIN with Porsche WMI "WP0" as Porsche', () {
      final result = VinDecoder.decode('WP0AA29900S000001');

      expect(result.manufacturer, 'Porsche');
      expect(result.country, 'Germany');
      expect(result.isPreStandard, isFalse);
    });
  });

  group('Invalid VIN handling', () {
    test('short VIN "ABC123" returns isValid false', () {
      final result = VinDecoder.decode('ABC123');

      expect(result.isValid, isFalse);
    });

    test('13-char alphanumeric VIN not matching any pre-standard format returns invalid', () {
      // 13 characters but structured so it does not match GM, Ford,
      // or any Italian pre-standard pattern.
      final result = VinDecoder.decode('XYZQWERT12345');

      expect(result.isValid, isFalse);
    });
  });
}
