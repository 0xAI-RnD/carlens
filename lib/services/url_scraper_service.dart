import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Dati estratti da un annuncio online di auto.
class ListingData {
  /// Foto scaricate come bytes (max 3).
  final List<Uint8List> imageBytes;

  /// URL originali delle immagini.
  final List<String> imageUrls;

  /// Prezzo richiesto (es. "€25.000").
  final String? askingPrice;

  /// Chilometraggio (es. "85.000 km").
  final String? mileage;

  /// Descrizione del venditore.
  final String? sellerDescription;

  /// Localita del venditore.
  final String? sellerLocation;

  /// URL originale dell'annuncio.
  final String sourceUrl;

  /// Nome leggibile del sito sorgente.
  final String sourceName;

  ListingData({
    required this.imageBytes,
    required this.imageUrls,
    this.askingPrice,
    this.mileage,
    this.sellerDescription,
    this.sellerLocation,
    required this.sourceUrl,
    required this.sourceName,
  });
}

/// Servizio per estrarre foto e dettagli da annunci auto online.
///
/// Supporta subito.it, autoscout24, autouncle e siti generici.
class UrlScraperService {
  // --- Public test helpers ---
  String detectSourceNamePublic(String url) => _detectSourceName(url);
  String formatPricePublic(num price) => _formatPrice(price);
  bool isValidUrl(String url) =>
      url.startsWith('http://') || url.startsWith('https://');

  /// Extract price from HTML for testing purposes.
  String? extractPriceFromHtml(String html) {
    final result = _parseSubito(html, 'https://www.subito.it');
    return result['price'] as String?;
  }

  /// Extract mileage from HTML for testing purposes.
  String? extractMileageFromHtml(String html) {
    final match =
        RegExp(r'([\d.]+)\s*km', caseSensitive: false).firstMatch(html);
    return match != null ? '${match.group(1)} km' : null;
  }

  static const Duration _pageTimeout = Duration(seconds: 15);
  static const Duration _imageTimeout = Duration(seconds: 10);
  static const int _maxImages = 3;
  static const int _minImageBytes = 10 * 1024; // 10 KB
  static const int _maxImageBytes = 10 * 1024 * 1024; // 10 MB

  static const Map<String, String> _defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7',
  };

  /// Estrae foto e dettagli da un URL di annuncio auto.
  ///
  /// Lancia un'eccezione con messaggio in italiano in caso di errore.
  Future<ListingData> scrapeListingUrl(String url) async {
    // Validazione URL
    final uri = Uri.tryParse(url);
    if (uri == null ||
        (!uri.scheme.startsWith('http') && !uri.scheme.startsWith('https'))) {
      throw Exception('URL non valido. Inserisci un link che inizi con http o https.');
    }

    // Scarica la pagina HTML
    final String html;
    try {
      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(_pageTimeout);

      if (response.statusCode == 403) {
        throw Exception(
          'Il sito ha bloccato la richiesta. Prova a scaricare le foto manualmente.',
        );
      }
      if (response.statusCode != 200) {
        throw Exception(
          'Impossibile accedere al sito. Controlla il link.',
        );
      }
      html = response.body;
    } on Exception catch (e) {
      if (e.toString().contains('bloccato') || e.toString().contains('accedere')) {
        rethrow;
      }
      throw Exception('Impossibile accedere al sito. Controlla il link.');
    }

    // Rileva il sito e analizza
    final host = uri.host.toLowerCase();
    final sourceName = _detectSourceName(url);
    final baseUrl = '${uri.scheme}://${uri.host}';

    List<String> imageUrls;
    String? askingPrice;
    String? mileage;
    String? sellerDescription;
    String? sellerLocation;

    if (host.contains('subito.it')) {
      final data = _parseSubito(html, baseUrl);
      imageUrls = data['images'] as List<String>;
      askingPrice = data['price'] as String?;
      mileage = data['mileage'] as String?;
      sellerDescription = data['description'] as String?;
      sellerLocation = data['location'] as String?;
    } else if (host.contains('autoscout24')) {
      final data = _parseAutoScout24(html, baseUrl);
      imageUrls = data['images'] as List<String>;
      askingPrice = data['price'] as String?;
      mileage = data['mileage'] as String?;
      sellerDescription = data['description'] as String?;
      sellerLocation = data['location'] as String?;
    } else if (host.contains('autouncle')) {
      final data = _parseAutoUncle(html, baseUrl);
      imageUrls = data['images'] as List<String>;
      askingPrice = data['price'] as String?;
      mileage = data['mileage'] as String?;
      sellerDescription = data['description'] as String?;
      sellerLocation = data['location'] as String?;
    } else {
      final data = _parseGeneric(html, baseUrl);
      imageUrls = data['images'] as List<String>;
      askingPrice = data['price'] as String?;
      mileage = data['mileage'] as String?;
      sellerDescription = data['description'] as String?;
      sellerLocation = data['location'] as String?;
    }

    if (imageUrls.isEmpty) {
      throw Exception("Nessuna foto trovata nell'annuncio.");
    }

    // Scarica le immagini (max 3)
    final downloadedImages = await _downloadImages(imageUrls);

    if (downloadedImages.isEmpty) {
      throw Exception("Nessuna foto trovata nell'annuncio.");
    }

    return ListingData(
      imageBytes: downloadedImages.map((e) => e.value).toList(),
      imageUrls: downloadedImages.map((e) => e.key).toList(),
      askingPrice: askingPrice,
      mileage: mileage,
      sellerDescription: sellerDescription,
      sellerLocation: sellerLocation,
      sourceUrl: url,
      sourceName: sourceName,
    );
  }

  // ---------------------------------------------------------------------------
  // Parser specifici per sito
  // ---------------------------------------------------------------------------

  /// Analizza un annuncio subito.it.
  Map<String, dynamic> _parseSubito(String html, String baseUrl) {
    final images = <String>[];

    // 1. Cerca immagini da __NEXT_DATA__ (JSON embedded)
    final nextDataMatch =
        RegExp(r'<script[^>]*id="__NEXT_DATA__"[^>]*>(.*?)</script>', dotAll: true)
            .firstMatch(html);
    if (nextDataMatch != null) {
      try {
        final jsonData = json.decode(nextDataMatch.group(1)!);
        _extractJsonImageUrls(jsonData, images);
      } catch (_) {
        // JSON parsing fallito, continua con altri metodi
      }
    }

    // 2. Cerca JSON-LD con immagini
    final jsonLdMatches =
        RegExp(r'<script[^>]*type="application/ld\+json"[^>]*>(.*?)</script>',
                dotAll: true)
            .allMatches(html);
    for (final match in jsonLdMatches) {
      try {
        final jsonData = json.decode(match.group(1)!);
        if (jsonData is Map && jsonData.containsKey('image')) {
          final img = jsonData['image'];
          if (img is String) {
            images.add(img);
          } else if (img is List) {
            images.addAll(img.whereType<String>());
          }
        }
      } catch (_) {}
    }

    // 3. og:image come fallback
    final ogImage = _extractMetaContent(html, 'og:image');
    if (ogImage != null && ogImage.isNotEmpty) {
      images.add(ogImage);
    }

    // Prezzo — priorità: 1) JSON-LD "price", 2) HTML con classe price, 3) meta tag, 4) regex
    String? price;

    // 1. Cerca nel JSON-LD (più affidabile)
    for (final match in jsonLdMatches) {
      try {
        final jsonData = json.decode(match.group(1)!);
        if (jsonData is Map) {
          // Direct "price" field
          final p = jsonData['price'];
          if (p != null) {
            final pNum = p is num ? p : num.tryParse(p.toString());
            if (pNum != null && pNum > 100) {
              price = '\u20AC${_formatPrice(pNum)}';
              break;
            }
          }
          // Nested "offers.price"
          final offers = jsonData['offers'];
          if (offers is Map && offers['price'] != null) {
            final op = offers['price'];
            final opNum = op is num ? op : num.tryParse(op.toString());
            if (opNum != null && opNum > 100) {
              price = '\u20AC${_formatPrice(opNum)}';
              break;
            }
          }
        }
      } catch (_) {}
    }

    // 2. Cerca pattern "X.XXX €" nel HTML (formato italiano)
    if (price == null) {
      final htmlPriceMatch = RegExp(r'(\d{1,3}(?:\.\d{3})+)\s*€').firstMatch(html);
      if (htmlPriceMatch != null) {
        price = '\u20AC${htmlPriceMatch.group(1)}';
      }
    }

    // 3. Meta tag (skip values < 100 — spesso sono rating/stelle)
    if (price == null) {
      final metaPrice = _extractMetaContent(html, 'product:price:amount');
      if (metaPrice != null && metaPrice.isNotEmpty) {
        final metaNum = num.tryParse(metaPrice);
        if (metaNum != null && metaNum > 100) {
          price = '\u20AC${_formatPrice(metaNum)}';
        }
      }
    }

    // Chilometraggio
    final kmMatch =
        RegExp(r'([\d.]+)\s*km', caseSensitive: false).firstMatch(html);
    final mileage = kmMatch != null ? '${kmMatch.group(1)} km' : null;

    // Descrizione
    final description = _extractMetaContent(html, 'og:description');

    // Localita
    String? location;
    final locationMatch =
        RegExp(r'"town"\s*:\s*"([^"]+)"').firstMatch(html);
    location = locationMatch?.group(1);
    location ??= _extractMetaContent(html, 'og:locality');

    return {
      'images': _deduplicateUrls(images),
      'price': price,
      'mileage': mileage,
      'description': description,
      'location': location,
    };
  }

  /// Analizza un annuncio autoscout24.
  Map<String, dynamic> _parseAutoScout24(String html, String baseUrl) {
    final images = <String>[];

    // og:image
    final ogImage = _extractMetaContent(html, 'og:image');
    if (ogImage != null && ogImage.isNotEmpty) {
      images.add(ogImage);
    }

    // Cerca URL immagini nella gallery (pattern tipico autoscout24)
    final galleryMatches = RegExp(
      r"""https?://[^"'\s]+(?:\.jpg|\.jpeg|\.png|\.webp)(?:\?[^"'\s]*)?""",
      caseSensitive: false,
    ).allMatches(html);
    for (final match in galleryMatches) {
      final imgUrl = match.group(0)!;
      if (_isCarImageUrl(imgUrl)) {
        images.add(imgUrl);
      }
    }

    // Cerca data-src nelle immagini gallery
    final dataSrcMatches =
        RegExp(r'data-src="(https?://[^"]+)"').allMatches(html);
    for (final match in dataSrcMatches) {
      final imgUrl = match.group(1)!;
      if (_isCarImageUrl(imgUrl)) {
        images.add(imgUrl);
      }
    }

    // Prezzo: data-price o pattern
    String? price;
    final dataPriceMatch =
        RegExp(r'data-price="([\d.]+)"').firstMatch(html);
    if (dataPriceMatch != null) {
      price = '\u20AC${dataPriceMatch.group(1)}';
    } else {
      final priceMatch =
          RegExp(r'[€EUR]\s?([\d.]+(?:,\d{2})?)').firstMatch(html);
      price = priceMatch != null ? '\u20AC${priceMatch.group(1)}' : null;
    }

    // Chilometraggio
    final kmMatch =
        RegExp(r'([\d.]+)\s*km', caseSensitive: false).firstMatch(html);
    final mileage = kmMatch != null ? '${kmMatch.group(1)} km' : null;

    // Descrizione
    final description = _extractMetaContent(html, 'og:description');

    // Localita
    String? location;
    final locationMatch =
        RegExp(r'"location"\s*:\s*\{[^}]*"city"\s*:\s*"([^"]+)"')
            .firstMatch(html);
    location = locationMatch?.group(1);

    return {
      'images': _deduplicateUrls(images),
      'price': price,
      'mileage': mileage,
      'description': description,
      'location': location,
    };
  }

  /// Analizza un annuncio autouncle.
  Map<String, dynamic> _parseAutoUncle(String html, String baseUrl) {
    final images = <String>[];

    // og:image
    final ogImage = _extractMetaContent(html, 'og:image');
    if (ogImage != null && ogImage.isNotEmpty) {
      images.add(ogImage);
    }

    // Cerca URL immagini nel corpo della pagina
    final imgMatches = RegExp(
      r"""https?://[^"'\s]+(?:\.jpg|\.jpeg|\.png|\.webp)(?:\?[^"'\s]*)?""",
      caseSensitive: false,
    ).allMatches(html);
    for (final match in imgMatches) {
      final imgUrl = match.group(0)!;
      if (_isCarImageUrl(imgUrl)) {
        images.add(imgUrl);
      }
    }

    // Prezzo
    final priceMatch =
        RegExp(r'[€EUR]\s?([\d.]+(?:,\d{2})?)').firstMatch(html);
    final price =
        priceMatch != null ? '\u20AC${priceMatch.group(1)}' : null;

    // Chilometraggio
    final kmMatch =
        RegExp(r'([\d.]+)\s*km', caseSensitive: false).firstMatch(html);
    final mileage = kmMatch != null ? '${kmMatch.group(1)} km' : null;

    // Descrizione
    final description = _extractMetaContent(html, 'og:description');

    return {
      'images': _deduplicateUrls(images),
      'price': price,
      'mileage': mileage,
      'description': description,
      'location': null,
    };
  }

  /// Parser generico per siti non riconosciuti.
  Map<String, dynamic> _parseGeneric(String html, String baseUrl) {
    final images = <String>[];

    // 1. Priorita a og:image
    final ogImage = _extractMetaContent(html, 'og:image');
    if (ogImage != null && ogImage.isNotEmpty) {
      images.add(_resolveUrl(ogImage, baseUrl));
    }

    // 2. Tutti i tag <img>
    final allImgUrls = _extractImageUrls(html, baseUrl);
    images.addAll(allImgUrls);

    // Prezzo
    final priceMatch =
        RegExp(r'[€EUR]\s?([\d.,]+)').firstMatch(html);
    final price =
        priceMatch != null ? '\u20AC${priceMatch.group(1)}' : null;

    // Chilometraggio
    final kmMatch =
        RegExp(r'([\d.,]+)\s*km', caseSensitive: false).firstMatch(html);
    final mileage = kmMatch != null ? '${kmMatch.group(1)} km' : null;

    // Descrizione
    final description = _extractMetaContent(html, 'og:description');

    return {
      'images': _deduplicateUrls(images),
      'price': price,
      'mileage': mileage,
      'description': description,
      'location': null,
    };
  }

  // ---------------------------------------------------------------------------
  // Metodi helper
  // ---------------------------------------------------------------------------

  /// Estrae il contenuto di un meta tag per property o name.
  String? _extractMetaContent(String html, String property) {
    // Cerca per property="..."
    final propertyMatch = RegExp(
      '<meta[^>]+property=["\']$property["\'][^>]+content=["\']([^"\']*)["\']',
      caseSensitive: false,
    ).firstMatch(html);
    if (propertyMatch != null) {
      return _decodeHtmlEntities(propertyMatch.group(1)!);
    }

    // Cerca con content prima di property
    final reverseMatch = RegExp(
      '<meta[^>]+content=["\']([^"\']*)["\'][^>]+property=["\']$property["\']',
      caseSensitive: false,
    ).firstMatch(html);
    if (reverseMatch != null) {
      return _decodeHtmlEntities(reverseMatch.group(1)!);
    }

    // Cerca per name="..."
    final nameMatch = RegExp(
      '<meta[^>]+name=["\']$property["\'][^>]+content=["\']([^"\']*)["\']',
      caseSensitive: false,
    ).firstMatch(html);
    if (nameMatch != null) {
      return _decodeHtmlEntities(nameMatch.group(1)!);
    }

    return null;
  }

  /// Estrae tutti gli URL delle immagini dai tag <img>, filtrando
  /// icone, loghi, tracker e immagini non pertinenti.
  List<String> _extractImageUrls(String html, String baseUrl) {
    final urls = <String>[];
    final imgMatches =
        RegExp(r"""<img[^>]+src=["']([^"']+)["']""", caseSensitive: false)
            .allMatches(html);

    for (final match in imgMatches) {
      final src = match.group(1)!;
      final resolved = _resolveUrl(src, baseUrl);

      if (_isCarImageUrl(resolved)) {
        urls.add(resolved);
      }
    }

    return urls;
  }

  /// Risolve un URL relativo rispetto al baseUrl.
  String _resolveUrl(String url, String baseUrl) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }
    return '$baseUrl/$url';
  }

  /// Restituisce il nome leggibile del sito sorgente dall'URL.
  String _formatPrice(num price) {
    if (price >= 1000) {
      final intPrice = price.round();
      final str = intPrice.toString();
      final buffer = StringBuffer();
      for (var i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
        buffer.write(str[i]);
      }
      return buffer.toString();
    }
    return price.toString();
  }

  String _detectSourceName(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    if (host.contains('subito.it')) return 'Subito.it';
    if (host.contains('autoscout24')) return 'AutoScout24';
    if (host.contains('autouncle')) return 'AutoUncle';
    return 'Altro';
  }

  /// Verifica se un URL immagine e probabilmente una foto di auto
  /// (esclude loghi, icone, tracker, ecc.).
  bool _isCarImageUrl(String url) {
    final lower = url.toLowerCase();

    // Escludi pattern non pertinenti
    const excludePatterns = [
      'logo',
      'icon',
      'favicon',
      'avatar',
      'banner',
      'sprite',
      'tracking',
      'pixel',
      'analytics',
      'ad/',
      'ads/',
      'badge',
      'button',
      'widget',
      'social',
      'facebook',
      'twitter',
      'linkedin',
      'instagram',
      'pinterest',
      'flag',
      'arrow',
      'placeholder',
      'blank.gif',
      'spacer',
      '1x1',
      'data:image',
      '.svg',
      '.gif',
    ];

    for (final pattern in excludePatterns) {
      if (lower.contains(pattern)) return false;
    }

    // Deve essere un formato immagine supportato
    final hasImageExtension = lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.webp');
    final hasImageInUrl = lower.contains('/image') ||
        lower.contains('/photo') ||
        lower.contains('/pic') ||
        lower.contains('/img');

    return hasImageExtension || hasImageInUrl;
  }

  /// Rimuove URL duplicati mantenendo l'ordine.
  List<String> _deduplicateUrls(List<String> urls) {
    final seen = <String>{};
    final result = <String>[];
    for (final url in urls) {
      // Normalizza rimuovendo query string per confronto
      final normalized = url.split('?').first.toLowerCase();
      if (seen.add(normalized)) {
        result.add(url);
      }
    }
    return result;
  }

  /// Scarica fino a [_maxImages] immagini, selezionando le piu grandi.
  ///
  /// Per il parser generico, controlla prima la dimensione via HEAD request,
  /// poi scarica le migliori.
  Future<List<MapEntry<String, Uint8List>>> _downloadImages(
    List<String> urls,
  ) async {
    final results = <MapEntry<String, Uint8List>>[];

    // Limita i candidati a 5 per il download
    final candidates = urls.take(5).toList();

    for (final url in candidates) {
      if (results.length >= _maxImages) break;

      try {
        final response = await http
            .get(Uri.parse(url), headers: _defaultHeaders)
            .timeout(_imageTimeout);

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;

          // Salta immagini troppo piccole (probabilmente icone)
          if (bytes.length < _minImageBytes) {
            debugPrint(
              'UrlScraperService: immagine troppo piccola '
              '(${bytes.length} bytes), saltata: $url',
            );
            continue;
          }

          // Salta immagini troppo grandi (probabilmente corrotte)
          if (bytes.length > _maxImageBytes) {
            debugPrint(
              'UrlScraperService: immagine troppo grande '
              '(${bytes.length} bytes), saltata: $url',
            );
            continue;
          }

          results.add(MapEntry(url, Uint8List.fromList(bytes)));
        }
      } catch (e) {
        debugPrint('UrlScraperService: errore download immagine $url: $e');
        // Continua con la prossima immagine
      }
    }

    // Ordina per dimensione decrescente e prendi le top 3
    results.sort((a, b) => b.value.length.compareTo(a.value.length));
    return results.take(_maxImages).toList();
  }

  /// Cerca ricorsivamente URL di immagini in una struttura JSON.
  void _extractJsonImageUrls(dynamic data, List<String> results) {
    if (data is String) {
      if ((data.contains('.jpg') ||
              data.contains('.jpeg') ||
              data.contains('.png') ||
              data.contains('.webp')) &&
          data.startsWith('http')) {
        results.add(data);
      }
      return;
    }

    if (data is List) {
      for (final item in data) {
        _extractJsonImageUrls(item, results);
      }
      return;
    }

    if (data is Map) {
      // Cerca chiavi comuni per array di immagini
      const imageKeys = ['images', 'image', 'photos', 'gallery', 'urls'];
      for (final key in data.keys) {
        final keyStr = key.toString().toLowerCase();
        if (imageKeys.any((k) => keyStr.contains(k))) {
          _extractJsonImageUrls(data[key], results);
        }
      }
      // Cerca anche in tutti i valori per non perdere niente
      for (final value in data.values) {
        if (value is Map || value is List) {
          _extractJsonImageUrls(value, results);
        }
      }
    }
  }

  /// Decodifica entita HTML comuni.
  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&apos;', "'");
  }
}
