import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/services/url_scraper_service.dart';

void main() {
  late UrlScraperService service;

  setUp(() {
    service = UrlScraperService();
  });

  group('Source name detection', () {
    test('detects Subito.it', () {
      expect(
        service.detectSourceNamePublic(
            'https://www.subito.it/auto/500-l-storica-639987820.htm'),
        equals('Subito.it'),
      );
    });

    test('detects AutoScout24', () {
      expect(
        service.detectSourceNamePublic(
            'https://www.autoscout24.it/annunci/fiat-500-12345'),
        equals('AutoScout24'),
      );
    });

    test('detects AutoUncle', () {
      expect(
        service.detectSourceNamePublic(
            'https://www.autouncle.it/auto/fiat-500'),
        equals('AutoUncle'),
      );
    });

    test('returns Altro for unknown sites', () {
      expect(
        service.detectSourceNamePublic('https://www.example.com/car'),
        equals('Altro'),
      );
    });
  });

  group('Price extraction from HTML', () {
    test('extracts price from JSON-LD (Subito.it pattern)', () {
      final html = '''
      <html>
      <script type="application/ld+json">
      {"@type":"Product","name":"Fiat 500","offers":{"price":6800,"priceCurrency":"EUR"}}
      </script>
      </html>
      ''';
      final price = service.extractPriceFromHtml(html);
      expect(price, isNotNull);
      expect(price, contains('6.800'));
    });

    test('extracts price from direct JSON-LD price field', () {
      final html = '''
      <html>
      <script type="application/ld+json">
      {"@type":"Product","name":"Alfa Romeo","price":25000,"priceCurrency":"EUR"}
      </script>
      </html>
      ''';
      final price = service.extractPriceFromHtml(html);
      expect(price, isNotNull);
      expect(price, contains('25.000'));
    });

    test('ignores price values less than 100 (rating/stars)', () {
      final html = '''
      <html>
      <meta property="product:price:amount" content="5"/>
      </html>
      ''';
      final price = service.extractPriceFromHtml(html);
      expect(price, isNull,
          reason: 'Price of 5 should be ignored — likely a rating');
    });

    test('extracts price from Italian format "X.XXX €"', () {
      final html = '''
      <html>
      <div class="price">6.800 €</div>
      </html>
      ''';
      final price = service.extractPriceFromHtml(html);
      expect(price, isNotNull);
      expect(price, contains('6.800'));
    });

    test('extracts price from "XX.XXX €" format', () {
      final html = '''
      <html>
      <span>25.000 €</span>
      </html>
      ''';
      final price = service.extractPriceFromHtml(html);
      expect(price, isNotNull);
      expect(price, contains('25.000'));
    });

    test('extracts valid meta price above 100', () {
      final html = '''
      <html>
      <meta property="product:price:amount" content="15000"/>
      </html>
      ''';
      final price = service.extractPriceFromHtml(html);
      expect(price, isNotNull);
      expect(price, contains('15.000'));
    });

    test('returns null when no price found', () {
      final html = '<html><body>No price here</body></html>';
      final price = service.extractPriceFromHtml(html);
      expect(price, isNull);
    });
  });

  group('Mileage extraction', () {
    test('extracts km from HTML', () {
      final html = '<div>85.000 km</div>';
      final km = service.extractMileageFromHtml(html);
      expect(km, isNotNull);
      expect(km, contains('85.000'));
    });

    test('returns null when no km found', () {
      final html = '<html><body>No mileage</body></html>';
      final km = service.extractMileageFromHtml(html);
      expect(km, isNull);
    });
  });

  group('URL validation', () {
    test('accepts valid https URL', () {
      expect(service.isValidUrl('https://www.subito.it/auto/test'), isTrue);
    });

    test('accepts valid http URL', () {
      expect(service.isValidUrl('http://www.subito.it/auto/test'), isTrue);
    });

    test('rejects non-URL string', () {
      expect(service.isValidUrl('not a url'), isFalse);
    });

    test('rejects empty string', () {
      expect(service.isValidUrl(''), isFalse);
    });
  });

  group('Price formatting', () {
    test('formats 6800 as 6.800', () {
      expect(service.formatPricePublic(6800), equals('6.800'));
    });

    test('formats 25000 as 25.000', () {
      expect(service.formatPricePublic(25000), equals('25.000'));
    });

    test('formats 150000 as 150.000', () {
      expect(service.formatPricePublic(150000), equals('150.000'));
    });

    test('formats 500 as 500', () {
      expect(service.formatPricePublic(500), equals('500'));
    });

    test('formats 1000000 as 1.000.000', () {
      expect(service.formatPricePublic(1000000), equals('1.000.000'));
    });
  });
}
