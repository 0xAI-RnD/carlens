import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CarIdentification {
  final String brand;
  final String model;
  final String yearEstimate;
  final String bodyType;
  final String color;
  final double confidence;
  final String details;
  final List<String> distinguishingFeatures;
  // Specifiche tecniche (sempre fornite da Gemini)
  final String engineCode;
  final String engineDisplacement;
  final String enginePower;
  final String transmissionType;
  final String transmissionBrand;
  final String weight;
  final String topSpeed;
  final String length;
  final String width;
  final String height;
  final String wheelbase;
  final String totalProduced;
  final String designer;
  final String funFact;
  final String marketValueRange;
  final List<String> timeline;
  final String keyDifference;

  CarIdentification({
    required this.brand,
    required this.model,
    required this.yearEstimate,
    required this.bodyType,
    required this.color,
    required this.confidence,
    required this.details,
    required this.distinguishingFeatures,
    this.engineCode = '',
    this.engineDisplacement = '',
    this.enginePower = '',
    this.transmissionType = '',
    this.transmissionBrand = '',
    this.weight = '',
    this.topSpeed = '',
    this.length = '',
    this.width = '',
    this.height = '',
    this.wheelbase = '',
    this.totalProduced = '',
    this.designer = '',
    this.funFact = '',
    this.marketValueRange = '',
    this.timeline = const [],
    this.keyDifference = '',
  });

  factory CarIdentification.fromJson(Map<String, dynamic> json) {
    final specs = json['specs'] as Map<String, dynamic>? ?? {};
    return CarIdentification(
      brand: json['brand'] as String? ?? 'Sconosciuto',
      model: json['model'] as String? ?? 'Sconosciuto',
      yearEstimate: json['year_estimate'] as String? ?? 'N/D',
      bodyType: json['body_type'] as String? ?? 'N/D',
      color: json['color'] as String? ?? 'N/D',
      confidence: _parseDouble(json['confidence']),
      details: json['details'] as String? ?? '',
      distinguishingFeatures:
          _parseStringList(json['distinguishing_features']),
      engineCode: specs['engine_code'] as String? ?? '',
      engineDisplacement: specs['displacement'] as String? ?? '',
      enginePower: specs['power'] as String? ?? '',
      transmissionType: specs['transmission'] as String? ?? '',
      transmissionBrand: specs['transmission_brand'] as String? ?? '',
      weight: specs['weight'] as String? ?? '',
      topSpeed: specs['top_speed'] as String? ?? '',
      length: specs['length'] as String? ?? '',
      width: specs['width'] as String? ?? '',
      height: specs['height'] as String? ?? '',
      wheelbase: specs['wheelbase'] as String? ?? '',
      totalProduced: specs['total_produced'] as String? ?? '',
      designer: specs['designer'] as String? ?? '',
      funFact: json['fun_fact'] as String? ?? '',
      marketValueRange: json['market_value_range'] as String? ?? '',
      timeline: _parseStringList(json['timeline']),
      keyDifference: json['key_difference'] as String? ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value.clamp(0.0, 1.0);
    if (value is int) return value.toDouble().clamp(0.0, 1.0);
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed != null ? parsed.clamp(0.0, 1.0) : 0.0;
    }
    return 0.0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'year_estimate': yearEstimate,
      'body_type': bodyType,
      'color': color,
      'confidence': confidence,
      'details': details,
      'distinguishing_features': distinguishingFeatures,
      'specs': {
        'engine_code': engineCode,
        'displacement': engineDisplacement,
        'power': enginePower,
        'transmission': transmissionType,
        'transmission_brand': transmissionBrand,
        'weight': weight,
        'top_speed': topSpeed,
        'length': length,
        'width': width,
        'height': height,
        'wheelbase': wheelbase,
        'total_produced': totalProduced,
        'designer': designer,
      },
      'fun_fact': funFact,
      'market_value_range': marketValueRange,
      'timeline': timeline,
      'key_difference': keyDifference,
    };
  }
}

class OriginalityReport {
  final double originalityScore;
  final bool engineMatch;
  final bool transmissionMatch;
  final bool bodyMatch;
  final List<String> notes;
  final String summary;

  OriginalityReport({
    required this.originalityScore,
    required this.engineMatch,
    required this.transmissionMatch,
    required this.bodyMatch,
    required this.notes,
    required this.summary,
  });

  factory OriginalityReport.fromJson(Map<String, dynamic> json) {
    return OriginalityReport(
      originalityScore: _parseScore(json['originality_score']),
      engineMatch: json['engine_match'] as bool? ?? false,
      transmissionMatch: json['transmission_match'] as bool? ?? false,
      bodyMatch: json['body_match'] as bool? ?? false,
      notes: _parseStringList(json['notes']),
      summary: json['summary'] as String? ?? '',
    );
  }

  static double _parseScore(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value.clamp(0.0, 100.0);
    if (value is int) return value.toDouble().clamp(0.0, 100.0);
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed != null ? parsed.clamp(0.0, 100.0) : 0.0;
    }
    return 0.0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _primaryModel = 'gemini-3.1-flash-lite-preview';
  static const String _fallbackModel2 = 'gemini-2.5-flash-lite';
  static const String _fallbackModel3 = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // Groq fallback
  static const String _groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _groqModel = 'meta-llama/llama-4-scout-17b-16e-instruct';
  static const String _groqBaseUrl = 'https://api.groq.com/openai/v1';

  Future<List<CarIdentification>> identifyCar(List<Uint8List> imageBytes) async {
    if (imageBytes.isEmpty) {
      throw Exception('Seleziona almeno una foto.');
    }

    const prompt = '''
Sei un esperto di auto classiche e d'epoca. Analizza attentamente le immagini fornite e identifica l'auto.

Rispondi ESCLUSIVAMENTE con un oggetto JSON valido (senza markdown, senza commenti) con questa struttura:
{
  "matches": [
    {
      "brand": "marca del costruttore",
      "model": "modello specifico",
      "year_estimate": "1968-1972",
      "body_type": "Coupé",
      "color": "Giallo Ocra",
      "confidence": 0.85,
      "details": "Descrizione di 2-3 frasi in italiano: storia, importanza, contesto storico del modello.",
      "distinguishing_features": ["fari tondi", "calandra a V", "linea Bertone"],
      "key_difference": "",
      "specs": {
        "engine_code": "AR 00526",
        "displacement": "1570 cc",
        "power": "106 CV @ 6.000 giri",
        "transmission": "5 marce manuale",
        "transmission_brand": "Alfa Romeo",
        "weight": "1.020 kg",
        "top_speed": "185 km/h",
        "length": "4.250 mm",
        "width": "1.600 mm",
        "height": "1.320 mm",
        "wheelbase": "2.350 mm",
        "total_produced": "21.902",
        "designer": "Bertone (Giugiaro)"
      },
      "fun_fact": "Una curiosità interessante e poco nota su questo modello, in italiano.",
      "market_value_range": "€25.000 - €45.000",
      "timeline": [
        "1963: Presentata al Salone di Francoforte",
        "1966: Introduzione versione 1600 GTV",
        "1969: Restyling con plancia aggiornata",
        "1976: Fine produzione dopo 21.902 esemplari"
      ]
    }
  ]
}

REGOLE IMPORTANTI:
- "matches" è un array di 1-3 possibili identificazioni, ordinate per confidence (la più alta per prima).
- Il primo match è l'identificazione principale.
- Ogni alternativa DEVE avere un campo "key_difference" che spiega in 1 frase (in italiano) cosa la distingue visivamente dal match principale.
- Il primo match ha "key_difference" vuoto ("").
- I valori di "confidence" devono sommare approssimativamente a 1.0.
- Se sei molto sicuro (confidence > 0.90), puoi restituire solo 1 match.
- "confidence" è un valore tra 0 e 1.
- I valori in "specs" devono essere BREVI (max 5-6 parole). Mai frasi lunghe. Se non conosci un dato, scrivi "N/D".
- NON scrivere spiegazioni o parentesi nei campi specs. Solo il valore numerico/tecnico.
- "fun_fact": una curiosità interessante e poco nota, 1-2 frasi in italiano.
- "market_value_range": stima del range di mercato attuale per un esemplare in buone condizioni. Usa il formato "€XX.000 - €YY.000". Se è un restomod o esemplare unico, stima il valore della base originale.
- "timeline": 3-6 eventi chiave nella storia del modello, in ordine cronologico. Formato "ANNO: evento breve".
- "details": descrizione storica interessante in italiano, 2-3 frasi.
- Se non riesci a identificare l'auto, usa "Sconosciuto" e confidence basso.
''';

    final parts = <Map<String, dynamic>>[
      {'text': prompt},
    ];

    for (final bytes in imageBytes) {
      parts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(bytes),
        }
      });
    }

    final body = {
      'contents': [
        {'parts': parts}
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
      },
    };

    // Save for Groq fallback
    _lastTextPrompt = prompt;
    _lastImageBytes = imageBytes;

    final responseJson = await _callGemini(body);
    return _parseCarIdentifications(responseJson);
  }

  /// Parses the Gemini response into a list of CarIdentification objects.
  /// Supports both the new "matches" array format and the legacy single-object format.
  static List<CarIdentification> _parseCarIdentifications(Map<String, dynamic> json) {
    if (json.containsKey('matches') && json['matches'] is List) {
      final matchesList = json['matches'] as List;
      if (matchesList.isEmpty) {
        throw const FormatException('La risposta AI non contiene identificazioni.');
      }
      return matchesList
          .whereType<Map<String, dynamic>>()
          .map((m) => CarIdentification.fromJson(m))
          .toList();
    }
    // Backward compatibility: single object without "matches" wrapper
    return [CarIdentification.fromJson(json)];
  }

  Future<OriginalityReport> generateOriginalityReport(
    String carModel,
    String vin,
    Map<String, dynamic> vinSpecs,
    Map<String, dynamic> carSpecs,
  ) async {
    final vinSpecsJson = const JsonEncoder.withIndent('  ').convert(vinSpecs);
    final carSpecsJson = const JsonEncoder.withIndent('  ').convert(carSpecs);

    final prompt = '''
Sei un esperto di auto classiche e d'epoca specializzato in perizie di originalità.

Devi confrontare le specifiche decodificate dal VIN con le specifiche note del modello per determinare quanto l'auto sia originale.

Auto: $carModel
VIN: $vin

Specifiche decodificate dal VIN:
$vinSpecsJson

Specifiche note del modello:
$carSpecsJson

Rispondi ESCLUSIVAMENTE con un oggetto JSON valido (senza markdown, senza commenti) con questa struttura:
{
  "originality_score": 85.0,
  "engine_match": true,
  "transmission_match": true,
  "body_match": true,
  "notes": [
    "Nota 1 in italiano sulla corrispondenza o discrepanza trovata",
    "Nota 2 in italiano",
    "Nota 3 in italiano"
  ],
  "summary": "Riassunto in italiano dell'analisi di originalità dell'auto, con giudizio complessivo."
}

Regole:
- "originality_score" è un valore da 0 a 100 dove 100 significa completamente originale.
- "engine_match" indica se il motore corrisponde a quello originale previsto per questo modello/anno.
- "transmission_match" indica se il cambio corrisponde a quello originale.
- "body_match" indica se la carrozzeria corrisponde a quella originale.
- "notes" deve contenere osservazioni dettagliate in italiano su ogni aspetto confrontato.
- "summary" è un riassunto complessivo in italiano dell'analisi.

Se non hai informazioni sufficienti per un confronto completo, segnalalo nelle note e riduci il punteggio di conseguenza.
''';

    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
      },
    };

    // Save for Groq fallback (text-only, no images)
    _lastTextPrompt = prompt;
    _lastImageBytes = null;

    final responseJson = await _callGemini(body);
    return OriginalityReport.fromJson(responseJson);
  }

  // Store the last request's image data for Groq fallback
  List<Uint8List>? _lastImageBytes;
  String? _lastTextPrompt;

  Future<Map<String, dynamic>> _callGemini(Map<String, dynamic> body) async {
    // Try Gemini primary, then Gemini fallback, then Groq
    final response = await _tryModel(_primaryModel, body) ??
        await _tryModel(_fallbackModel2, body) ??
        await _tryModel(_fallbackModel3, body) ??
        await _tryGroq();

    if (response == null) {
      throw Exception(
          'Servizio AI temporaneamente non disponibile. Riprova tra qualche istante.');
    }

    return response;
  }

  Future<Map<String, dynamic>?> _tryGroq() async {
    if (_lastTextPrompt == null) return null;

    final url = Uri.parse('$_groqBaseUrl/chat/completions');

    try {
      // Build messages for Groq (OpenAI-compatible format)
      final contentParts = <Map<String, dynamic>>[
        {'type': 'text', 'text': _lastTextPrompt!},
      ];

      // Add images if available
      if (_lastImageBytes != null) {
        for (final bytes in _lastImageBytes!) {
          contentParts.add({
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,${base64Encode(bytes)}',
            },
          });
        }
      }

      final groqBody = {
        'model': _groqModel,
        'messages': [
          {
            'role': 'user',
            'content': contentParts,
          }
        ],
        'temperature': 0.3,
        'max_tokens': 4096,
        'response_format': {'type': 'json_object'},
      };

      debugPrint('Trying Groq fallback ($_groqModel)...');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_groqApiKey',
            },
            body: jsonEncode(groqBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        debugPrint('Groq error: ${response.statusCode} ${response.body}');
        return null;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List?;
      if (choices == null || choices.isEmpty) return null;

      final message = choices[0]['message'] as Map<String, dynamic>?;
      final text = message?['content'] as String? ?? '';
      if (text.trim().isEmpty) return null;

      return _parseJsonResponse(text);
    } on http.ClientException {
      debugPrint('Groq: connection error');
      return null;
    } catch (e) {
      debugPrint('Groq: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _tryModel(
      String modelName, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/$modelName:generateContent');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': _apiKey,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 503 || response.statusCode == 429) {
        debugPrint('Model $modelName unavailable (${response.statusCode}), trying fallback...');
        return null; // triggers fallback
      }

      if (response.statusCode != 200) {
        debugPrint('Model $modelName error: ${response.statusCode}');
        return null;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Nessuna risposta dal servizio AI. Riprova.');
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('Nessuna risposta dal servizio AI. Riprova.');
      }

      final text = parts[0]['text'] as String? ?? '';
      if (text.trim().isEmpty) {
        throw Exception('Nessuna risposta dal servizio AI. Riprova.');
      }

      return _parseJsonResponse(text);
    } on http.ClientException {
      debugPrint('Model $modelName: connection error');
      return null;
    } on FormatException {
      debugPrint('Model $modelName: invalid response format');
      return null;
    } catch (e) {
      debugPrint('Model $modelName: $e');
      return null;
    }
  }

  Map<String, dynamic> _parseJsonResponse(String text) {
    var cleaned = text.trim();

    final fencePattern = RegExp(
      r'^```(?:json)?\s*\n?(.*?)\n?\s*```$',
      dotAll: true,
    );
    final fenceMatch = fencePattern.firstMatch(cleaned);
    if (fenceMatch != null) {
      cleaned = fenceMatch.group(1)!.trim();
    }

    final decoded = jsonDecode(cleaned);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Risposta AI non valida.');
  }
}
