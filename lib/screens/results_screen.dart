import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/gemini_service.dart';
import '../services/car_data_service.dart';
import '../services/database_service.dart';
import '../models/car_scan.dart';
import '../services/analytics_service.dart';
import '../services/telegram_service.dart';
import '../services/url_scraper_service.dart';
import '../utils/vin_decoder.dart';
import 'vin_helper_screen.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final List<String>? extraImagePaths;
  final CarScan? existingScan;
  final String? listingUrl;
  final String scanSource;

  const ResultScreen({
    super.key,
    required this.imagePath,
    this.extraImagePaths,
    this.existingScan,
    this.listingUrl,
    this.scanSource = 'camera',
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  // Design system
  static const _bgColor = Color(0xFFFAFAF8);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textSecondary = Color(0xFF8C8C8C);
  static const _textTertiary = Color(0xFFB0B0B0);
  static const _borderColor = Color(0xFFE8E8E6);
  static const _surfaceLight = Color(0xFFF0F0EE);
  static const _accentRed = Color(0xFFC4342D);

  // State
  int _currentLevel = 1;
  bool _isLoading = true;
  String? _errorMessage;

  CarIdentification? _identification;
  List<CarIdentification> _alternatives = [];
  VinResult? _vinResult;
  OriginalityReport? _originalityReport;
  Map<String, dynamic>? _carData;
  CarScan? _scan;

  ListingData? _listingData;
  String? _listingImagePath; // temp file path for listing's first image

  bool _showVinInput = false;
  bool _vinDecoding = false;
  bool _generatingReport = false;
  final TextEditingController _vinController = TextEditingController();

  final GeminiService _geminiService = GeminiService();
  final CarDataService _carDataService = CarDataService();
  final DatabaseService _databaseService = DatabaseService();

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _identifyCar();
  }

  @override
  void dispose() {
    _vinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Business logic (unchanged)
  // ---------------------------------------------------------------------------

  Future<void> _identifyCar() async {
    // If we have an existing scan from Garage, restore its data without calling Gemini
    if (widget.existingScan != null) {
      final scan = widget.existingScan!;

      // Parse extra data if available
      Map<String, dynamic> extra = {};
      if (scan.extraData != null && scan.extraData!.isNotEmpty) {
        try {
          extra = jsonDecode(scan.extraData!) as Map<String, dynamic>;
        } catch (_) {}
      }

      final restoredId = CarIdentification(
        brand: scan.brand,
        model: scan.model,
        yearEstimate: scan.yearEstimate,
        bodyType: scan.bodyType,
        color: scan.color,
        confidence: scan.confidence,
        details: scan.details,
        distinguishingFeatures: (extra['distinguishing_features'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        engineCode: extra['engine_code'] as String? ?? '',
        engineDisplacement: extra['displacement'] as String? ?? '',
        enginePower: extra['power'] as String? ?? '',
        transmissionType: extra['transmission'] as String? ?? '',
        transmissionBrand: extra['transmission_brand'] as String? ?? '',
        weight: extra['weight'] as String? ?? '',
        topSpeed: extra['top_speed'] as String? ?? '',
        totalProduced: extra['total_produced'] as String? ?? '',
        designer: extra['designer'] as String? ?? '',
        funFact: extra['fun_fact'] as String? ?? '',
        marketValueRange: extra['market_value_range'] as String? ?? '',
        length: extra['length'] as String? ?? '',
        width: extra['width'] as String? ?? '',
        height: extra['height'] as String? ?? '',
        wheelbase: extra['wheelbase'] as String? ?? '',
        timeline: (extra['timeline'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

      // Restore originality report if previously saved
      OriginalityReport? restoredReport;
      if (scan.originalityScore != null && scan.originalityReport != null) {
        restoredReport = OriginalityReport(
          originalityScore: scan.originalityScore!,
          engineMatch: extra['engine_match'] as bool? ?? true,
          transmissionMatch: extra['transmission_match'] as bool? ?? true,
          bodyMatch: extra['body_match'] as bool? ?? true,
          notes: (extra['originality_notes'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
          summary: scan.originalityReport!,
        );
      }

      await _carDataService.loadData();
      final carData = _carDataService.findByBrandModel(scan.brand, scan.model);

      // Restore VIN if previously saved
      VinResult? restoredVin;
      if (scan.vin != null && scan.vin!.isNotEmpty) {
        restoredVin = VinDecoder.decode(scan.vin!);
      }

      if (mounted) {
        setState(() {
          _identification = restoredId;
          _carData = carData;
          _scan = scan;
          _isLoading = false;
          if (restoredReport != null) {
            _originalityReport = restoredReport;
          }
          if (restoredVin != null) {
            _vinResult = restoredVin;
            _vinController.text = scan.vin!;
            _currentLevel = 2;
          }
        });
      }
      return;
    }

    // If opened from a marketplace listing URL, scrape it first
    if (widget.listingUrl != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final listing = await UrlScraperService().scrapeListingUrl(widget.listingUrl!);
        _listingData = listing;

        // Save first image to temp file for display & storage
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/carlens_listing_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(listing.imageBytes.first);
        _listingImagePath = tempFile.path;

        // Identify car using scraped images
        final results = await _geminiService.identifyCar(listing.imageBytes);
        final identification = results.first;
        final alternatives = results.length > 1 ? results.sublist(1) : <CarIdentification>[];

        await _carDataService.loadData();
        final carData = _carDataService.findByBrandModel(
          identification.brand,
          identification.model,
        );

        if (mounted) {
          setState(() {
            _identification = identification;
            _alternatives = alternatives;
            _carData = carData;
            _isLoading = false;
          });

          // Telegram notification (fire-and-forget)
          TelegramService().notifyMarketplaceScan(
            brand: identification.brand,
            model: identification.model,
            yearEstimate: identification.yearEstimate,
            bodyType: identification.bodyType,
            confidence: identification.confidence,
            sourceUrl: _listingData!.sourceUrl,
            sourceName: _listingData!.sourceName,
            askingPrice: _listingData!.askingPrice,
            mileage: _listingData!.mileage,
            imagePath: _listingImagePath ?? widget.imagePath,
          );

          // Analytics (fire-and-forget)
          final yearMatch = RegExp(r'(1[89]\d{2}|20\d{2})').firstMatch(identification.yearEstimate);
          final yearInt = yearMatch != null ? int.parse(yearMatch.group(1)!) : 0;
          AnalyticsService().logScanCompleted(
            brand: identification.brand,
            model: identification.model,
            year: yearInt,
            confidence: identification.confidence,
            source: widget.scanSource,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString().contains('Exception: ')
                ? e.toString().replaceFirst('Exception: ', '')
                : 'Si \u00e8 verificato un errore. Riprova.';
          });
        }
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final allBytes = <Uint8List>[bytes];

      // Add extra photos if available
      if (widget.extraImagePaths != null) {
        for (final path in widget.extraImagePaths!) {
          final extraFile = File(path);
          if (await extraFile.exists()) {
            allBytes.add(await extraFile.readAsBytes());
          }
        }
      }

      final results = await _geminiService.identifyCar(allBytes);
      final identification = results.first;
      final alternatives = results.length > 1 ? results.sublist(1) : <CarIdentification>[];

      await _carDataService.loadData();
      final carData = _carDataService.findByBrandModel(
        identification.brand,
        identification.model,
      );

      if (mounted) {
        setState(() {
          _identification = identification;
          _alternatives = alternatives;
          _carData = carData;
          _isLoading = false;
        });

        // Telegram notification (fire-and-forget)
        TelegramService().notifyNewScan(
          brand: identification.brand,
          model: identification.model,
          yearEstimate: identification.yearEstimate,
          bodyType: identification.bodyType,
          confidence: identification.confidence,
          level: 1,
          imagePath: widget.imagePath,
        );

        // Analytics (fire-and-forget)
        final yearMatch = RegExp(r'(1[89]\d{2}|20\d{2})').firstMatch(identification.yearEstimate);
        final yearInt = yearMatch != null ? int.parse(yearMatch.group(1)!) : 0;
        AnalyticsService().logScanCompleted(
          brand: identification.brand,
          model: identification.model,
          year: yearInt,
          confidence: identification.confidence,
          source: widget.scanSource,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().contains('Exception: ')
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Si \u00e8 verificato un errore. Riprova.';
        });
      }
    }
  }

  Future<void> _scanVinWithCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );
    if (image == null || !mounted) return;

    // Show processing indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lettura targhetta in corso...'),
        duration: Duration(seconds: 2),
      ),
    );

    final textRecognizer = TextRecognizer();
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Look for VIN-like patterns in recognized text
      String? foundVin;
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final text = line.text.replaceAll(' ', '').toUpperCase();
          // Standard 17-char VIN
          if (text.length == 17 && RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(text)) {
            foundVin = text;
            break;
          }
          // Pre-1981 Italian VINs (AR, AM, ZAR, ZFA patterns) with upper bound
          if (RegExp(r'^(AR|AM|ZAR|ZFA|ZFF|ZLA|ZHW)\s?[\d.]{4,20}$').hasMatch(text)) {
            foundVin = text;
            break;
          }
        }
        if (foundVin != null) break;
      }

      if (mounted) {
        if (foundVin != null) {
          _vinController.text = foundVin;
          setState(() => _showVinInput = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Telaio trovato: $foundVin'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nessun numero di telaio riconosciuto. Prova ad avvicinare la fotocamera.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore nella lettura. Inserisci il telaio manualmente.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      await textRecognizer.close();
    }
  }

  Future<void> _decodeVin() async {
    final vin = _vinController.text.trim().replaceAll(RegExp(r'[^A-Za-z0-9.\-\s]'), '').toUpperCase();
    if (vin.isEmpty) return;
    _vinController.text = vin;

    setState(() => _vinDecoding = true);

    try {
      final vinResult = VinDecoder.decode(vin);
      if (!vinResult.isValid && vinResult.manufacturer.isEmpty) {
        if (mounted) {
          setState(() => _vinDecoding = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Formato telaio non riconosciuto. Controlla e riprova.'),
              backgroundColor: _accentRed,
            ),
          );
        }
        return;
      }

      if (mounted) {
        if (!vinResult.isValid && vinResult.manufacturer.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Attenzione: il check digit non corrisponde. I VIN europei spesso non lo utilizzano.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _vinResult = vinResult;
          _currentLevel = 2;
          _vinDecoding = false;
          _showVinInput = false;
        });

        // Persist VIN to DB if scan is already saved
        if (_scan != null && _scan!.id != null) {
          final updated = _scan!.copyWith(vin: vin, level: 2);
          await _databaseService.updateScan(updated);
          _scan = updated;
        }

        // Telegram notification for VIN addition
        if (_identification != null) {
          TelegramService().notifyVinAdded(
            brand: _identification!.brand,
            model: _identification!.model,
            vin: vin,
            decodedManufacturer: vinResult.manufacturer,
            decodedYear: vinResult.year,
          );
        }

        // Auto-trigger originality report (merges old L2+L3 into single step)
        _generateOriginalityReport();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _vinDecoding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Errore nella decodifica del telaio. Controlla e riprova.'),
            backgroundColor: _accentRed,
          ),
        );
      }
    }
  }

  Future<void> _generateOriginalityReport() async {
    if (_identification == null || _vinResult == null) return;

    setState(() => _generatingReport = true);

    try {
      final vin = _vinResult!.rawVin;
      var vinSpecs = VinDecoder.getOriginalSpecs(
        vin,
        identifiedModel:
            '${_identification!.brand} ${_identification!.model}',
      );

      // Use local DB data if available, otherwise build specs from Gemini L1
      Map<String, dynamic> carSpecs;
      if (_carData != null && _carData!.isNotEmpty) {
        carSpecs = _carData!;
      } else {
        // Fallback: use the specs Gemini already provided at L1
        final id = _identification!;
        carSpecs = <String, dynamic>{
          'brand': id.brand,
          'model': id.model,
          'year_estimate': id.yearEstimate,
          'body_type': id.bodyType,
          'engine_code': id.engineCode,
          'engine_displacement': id.engineDisplacement,
          'engine_power': id.enginePower,
          'transmission': id.transmissionType,
          'transmission_brand': id.transmissionBrand,
          'weight': id.weight,
          'top_speed': id.topSpeed,
          'total_produced': id.totalProduced,
          'designer': id.designer,
        };
      }

      // Enrich vinSpecs with VIN decoder result metadata
      if (vinSpecs.isEmpty || vinSpecs.values.every((v) => v == null)) {
        vinSpecs = <String, String?>{
          'manufacturer': _vinResult!.manufacturer,
          'country': _vinResult!.country,
          'year': _vinResult!.year?.toString(),
          'model_indicator': _vinResult!.modelIndicator,
          'assembly_plant': _vinResult!.assemblyPlant,
          'serial_number': _vinResult!.serialNumber,
          'is_pre_standard': _vinResult!.isPreStandard.toString(),
        };
      }

      final report = await _geminiService.generateOriginalityReport(
        '${_identification!.brand} ${_identification!.model}',
        vin,
        vinSpecs,
        carSpecs,
      );

      if (mounted) {
        setState(() {
          _originalityReport = report;
          _generatingReport = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _generatingReport = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Errore nella generazione del report. Riprova.'),
            backgroundColor: _accentRed,
          ),
        );
      }
    }
  }

  Future<void> _saveToGarage() async {
    if (_identification == null) return;

    try {
      final ident = _identification!;
      final extraData = jsonEncode({
        'engine_code': ident.engineCode,
        'displacement': ident.engineDisplacement,
        'power': ident.enginePower,
        'transmission': ident.transmissionType,
        'transmission_brand': ident.transmissionBrand,
        'weight': ident.weight,
        'top_speed': ident.topSpeed,
        'length': ident.length,
        'width': ident.width,
        'height': ident.height,
        'wheelbase': ident.wheelbase,
        'total_produced': ident.totalProduced,
        'designer': ident.designer,
        'fun_fact': ident.funFact,
        'market_value_range': ident.marketValueRange,
        'timeline': ident.timeline,
        'distinguishing_features': ident.distinguishingFeatures,
        if (_originalityReport != null) ...{
          'engine_match': _originalityReport!.engineMatch,
          'transmission_match': _originalityReport!.transmissionMatch,
          'body_match': _originalityReport!.bodyMatch,
          'originality_notes': _originalityReport!.notes,
        },
      });

      final scan = CarScan(
        brand: ident.brand,
        model: ident.model,
        yearEstimate: ident.yearEstimate,
        bodyType: ident.bodyType,
        color: ident.color,
        confidence: ident.confidence,
        details: ident.details,
        vin: _vinResult?.rawVin,
        originalityScore: _originalityReport?.originalityScore,
        originalityReport: _originalityReport?.summary,
        imagePath: _listingImagePath ?? widget.imagePath,
        createdAt: DateTime.now(),
        level: _currentLevel,
        extraData: extraData,
        sourceUrl: _listingData?.sourceUrl,
        sourceName: _listingData?.sourceName,
        askingPrice: _listingData?.askingPrice,
        mileage: _listingData?.mileage,
      );

      final id = await _databaseService.insertScan(scan);

      // Telegram notification (fire-and-forget)
      TelegramService().notifyGarageSave(
        brand: ident.brand,
        model: ident.model,
        yearEstimate: ident.yearEstimate,
        bodyType: ident.bodyType,
        level: _currentLevel,
      );

      if (mounted) {
        setState(() {
          _scan = scan.copyWith(id: id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auto salvata nel Garage!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Errore nel salvataggio. Riprova.'),
            backgroundColor: _accentRed,
          ),
        );
      }
    }
  }

  /// Unified share method that works at any level (L1, L2, L3).
  /// Shares the car photo + structured text with all available info.
  Future<void> _shareCar() async {
    if (_identification == null) return;

    final id = _identification!;

    // Analytics (fire-and-forget)
    AnalyticsService().logCarShared(
      brand: id.brand,
      model: id.model,
    );

    final text = StringBuffer();

    // Header
    text.writeln(id.brand.toUpperCase());
    text.writeln('${id.model}');
    text.writeln('${id.yearEstimate} \u00b7 ${id.bodyType}');
    text.writeln('Attendibilit\u00e0 ricerca: ${(id.confidence * 100).round()}%');
    text.writeln();

    // Specs (always available after L1)
    if (id.engineDisplacement.isNotEmpty && id.engineDisplacement != 'N/D') {
      text.writeln('Motore: ${id.engineDisplacement}${id.engineCode.isNotEmpty ? ' ${id.engineCode}' : ''}');
    }
    if (id.enginePower.isNotEmpty && id.enginePower != 'N/D') {
      text.writeln('Potenza: ${id.enginePower}');
    }
    if (id.transmissionType.isNotEmpty && id.transmissionType != 'N/D') {
      text.writeln('Cambio: ${id.transmissionType}${id.transmissionBrand.isNotEmpty ? ' (${id.transmissionBrand})' : ''}');
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

    // Market value (if available)
    if (id.marketValueRange.isNotEmpty && id.marketValueRange != 'N/D') {
      text.writeln();
      text.writeln('Stima di mercato: ${id.marketValueRange}');
    }

    // L2: VIN data
    if (_vinResult != null) {
      text.writeln();
      text.writeln('Telaio: ${_vinResult!.rawVin}');
      if (_vinResult!.manufacturer.isNotEmpty && _vinResult!.manufacturer != 'Unknown') {
        text.writeln('Costruttore: ${_vinResult!.manufacturer}');
      }
      if (_vinResult!.year != null) {
        text.writeln('Anno (da VIN): ${_vinResult!.year}');
      }
    }

    // L3: Originality report
    if (_originalityReport != null) {
      final report = _originalityReport!;
      text.writeln();
      text.writeln('Originalit\u00e0: ${report.originalityScore.toStringAsFixed(0)}%');
      text.writeln('Motore: ${report.engineMatch ? "Conforme" : "Non conforme"}');
      text.writeln('Cambio: ${report.transmissionMatch ? "Conforme" : "Non conforme"}');
      text.writeln('Carrozzeria: ${report.bodyMatch ? "Conforme" : "Non conforme"}');
    }

    text.writeln();
    text.writeln('Analizzato con CarLens');

    // Share with photo
    final effectivePath = _listingImagePath ?? widget.imagePath;
    final file = File(effectivePath);
    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(effectivePath)],
        text: text.toString(),
      );
    } else {
      await Share.share(text.toString());
    }
  }

  void _retry() {
    setState(() {
      _currentLevel = 1;
      _isLoading = true;
      _errorMessage = null;
      _identification = null;
      _alternatives = [];
      _vinResult = null;
      _originalityReport = null;
      _carData = null;
      _scan = null;
      _showVinInput = false;
      _vinDecoding = false;
      _generatingReport = false;
      _vinController.clear();
    });
    _identifyCar();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingView()
            : _errorMessage != null
                ? _buildErrorView()
                : _currentLevel >= 2 && _vinResult != null
                    ? _buildL2View()
                    : _buildL1View(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header back
  // ---------------------------------------------------------------------------

  Widget _buildHeaderBack(String title) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_ios, size: 16, color: _textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.3 + (_pulseController.value * 0.7),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: _textSecondary,
                  size: 64,
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: _textPrimary,
              strokeWidth: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.listingUrl != null
                ? 'Analisi annuncio in corso...'
                : 'Analisi in corso...',
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.listingUrl != null
                ? 'Scaricamento foto e identificazione'
                : 'L\'AI sta identificando l\'auto',
            style: const TextStyle(color: _textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error
  // ---------------------------------------------------------------------------

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentRed.withOpacity(0.08),
              ),
              child: Icon(Icons.error_outline_rounded,
                  color: _accentRed, size: 44),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Riprova',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _textPrimary,
                  foregroundColor: _bgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // L1 View
  // ---------------------------------------------------------------------------

  Widget _buildL1View() {
    final id = _identification!;
    final percent = (id.confidence * 100).round();

    return Column(
      children: [
        _buildHeaderBack('Risultato'),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Car photo - edge to edge, 260px
                SizedBox(
                  width: double.infinity,
                  height: 260,
                  child: Image.file(
                    File(_listingImagePath ?? widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),

                // Result body
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand
                      Text(
                        id.brand.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: _textSecondary,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Model
                      Text(
                        id.model,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Years + body
                      Text(
                        '${id.yearEstimate}${id.bodyType.isNotEmpty ? ' \u00b7 ${id.bodyType}' : ''}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: _textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                size: 13, color: _textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              'Identificato \u00b7 $percent%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // (confidence now shown in the badge above)

                      // Divider
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(color: _borderColor, height: 1),
                      ),

                      // SCHEDA RAPIDA section — always shown
                      const Text(
                        'SCHEDA RAPIDA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildQuickSpecs(),

                      // Details / description
                      if (id.details.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: _borderColor, height: 1),
                        ),
                        Text(
                          id.details,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: _textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],

                      // Market value estimate
                      if (id.marketValueRange.isNotEmpty && id.marketValueRange != 'N/D') ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: _borderColor, height: 1),
                        ),
                        _buildMarketValueCard(id.marketValueRange),
                      ],

                      // Listing data section
                      if (_listingData != null || _scan?.askingPrice != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: _borderColor, height: 1),
                        ),
                        _buildListingDataSection(),
                      ],

                      // Timeline
                      if (id.timeline.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: _borderColor, height: 1),
                        ),
                        _buildTimeline(id.timeline),
                      ],

                      // Fun fact
                      if (id.funFact.isNotEmpty && id.funFact != 'N/D') ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: _borderColor, height: 1),
                        ),
                        _buildFunFact(id.funFact),
                      ],

                      // Alternative matches
                      if (_alternatives.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: _borderColor, height: 1),
                        ),
                        _buildAlternativesSection(),
                      ],

                      // VIN invite card
                      Container(
                        margin: const EdgeInsets.only(top: 32),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderColor, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vuoi saperne di pi\u00f9?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Inserisci il numero di telaio per scoprire le specifiche esatte del tuo esemplare.',
                              style: TextStyle(
                                fontSize: 13,
                                color: _textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _vinController,
                                    maxLength: 25,
                                    style: const TextStyle(
                                      color: _textPrimary,
                                      fontSize: 14,
                                    ),
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _decodeVin(),
                                    decoration: InputDecoration(
                                      hintText: 'Inserisci telaio',
                                      hintStyle: const TextStyle(
                                          color: Color(0xFFCCCCCC)),
                                      filled: true,
                                      fillColor: _bgColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: _borderColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: _borderColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: _textPrimary),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _scanVinWithCamera,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _textPrimary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const VinHelperScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(bottom: 1),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: _borderColor, width: 1),
                                  ),
                                ),
                                child: const Text(
                                  'Dove trovo il telaio? \u24d8',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed:
                                    _vinDecoding ? null : _decodeVin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _textPrimary,
                                    foregroundColor: _bgColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _vinDecoding
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            color: _bgColor,
                                          ),
                                        )
                                      : const Text(
                                          'Decodifica',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Correction link
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Grazie per il feedback! Riprova con un\'altra foto.'),
                                ),
                              );
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.only(bottom: 1),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: _borderColor, width: 1),
                                ),
                              ),
                              child: const Text(
                                'Non \u00e8 questa auto? Correggi \u2192',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Condividi button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _shareCar,
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: const Text(
                            'Condividi scheda',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _textPrimary,
                            side: const BorderSide(color: _borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              _scan != null ? null : _saveToGarage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _scan != null
                                ? const Color(0xFF4CAF50)
                                : _textPrimary,
                            foregroundColor: _bgColor,
                            disabledBackgroundColor:
                                const Color(0xFF4CAF50),
                            disabledForegroundColor: Colors.white70,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _scan != null
                                ? 'Salvata nel Garage'
                                : 'Salva nel Garage',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildQuickSpecs() {
    final id = _identification!;
    final data = _carData;
    final specs = <_SpecEntry>[];

    // Motore: prefer DB, fallback to Gemini
    final engineDisp = data?['engine_displacement_cc']?.toString() ?? '';
    final engineCode = data?['engine_code']?.toString() ?? id.engineCode;
    final geminiDisp = id.engineDisplacement;
    if (engineDisp.isNotEmpty && engineCode.isNotEmpty) {
      specs.add(_SpecEntry('Motore', '${engineDisp}cc $engineCode'));
    } else if (geminiDisp.isNotEmpty) {
      specs.add(_SpecEntry('Motore', engineCode.isNotEmpty ? '$geminiDisp $engineCode' : geminiDisp));
    }

    // Potenza
    final hp = data?['engine_hp']?.toString() ?? '';
    final geminiPower = id.enginePower;
    if (hp.isNotEmpty) {
      specs.add(_SpecEntry('Potenza', '$hp CV'));
    } else if (geminiPower.isNotEmpty && geminiPower != 'N/D') {
      specs.add(_SpecEntry('Potenza', geminiPower));
    }

    // Cambio
    final txSpeeds = data?['transmission_speeds']?.toString() ?? '';
    final txBrand = data?['transmission_brand']?.toString() ?? id.transmissionBrand;
    final geminiTx = id.transmissionType;
    if (txSpeeds.isNotEmpty) {
      final txLabel = txBrand.isNotEmpty ? '$txSpeeds marce ($txBrand)' : '$txSpeeds marce';
      specs.add(_SpecEntry('Cambio', txLabel));
    } else if (geminiTx.isNotEmpty && geminiTx != 'N/D') {
      specs.add(_SpecEntry('Cambio', txBrand.isNotEmpty && !geminiTx.contains(txBrand) ? '$geminiTx ($txBrand)' : geminiTx));
    }

    // Peso
    final weight = data?['weight_kg']?.toString() ?? '';
    final geminiWeight = id.weight;
    if (weight.isNotEmpty) {
      specs.add(_SpecEntry('Peso', '$weight kg'));
    } else if (geminiWeight.isNotEmpty && geminiWeight != 'N/D') {
      specs.add(_SpecEntry('Peso', geminiWeight));
    }

    // Velocità max
    final topSpeed = data?['top_speed_kmh']?.toString() ?? '';
    final geminiTopSpeed = id.topSpeed;
    if (topSpeed.isNotEmpty) {
      specs.add(_SpecEntry('Velocit\u00e0 max', '$topSpeed km/h'));
    } else if (geminiTopSpeed.isNotEmpty && geminiTopSpeed != 'N/D') {
      specs.add(_SpecEntry('Velocit\u00e0 max', geminiTopSpeed));
    }

    // Dimensioni
    if (id.length.isNotEmpty && id.length != 'N/D') {
      final dims = <String>[id.length];
      if (id.width.isNotEmpty && id.width != 'N/D') dims.add(id.width);
      if (id.height.isNotEmpty && id.height != 'N/D') dims.add(id.height);
      specs.add(_SpecEntry('Dimensioni', dims.join(' \u00d7 ')));
    }
    if (id.wheelbase.isNotEmpty && id.wheelbase != 'N/D') {
      specs.add(_SpecEntry('Passo', id.wheelbase));
    }

    // Produzione
    final produced = data?['total_produced']?.toString() ?? '';
    final geminiProduced = id.totalProduced;
    if (produced.isNotEmpty) {
      specs.add(_SpecEntry('Produzione', '$produced esemplari'));
    } else if (geminiProduced.isNotEmpty && geminiProduced != 'N/D') {
      specs.add(_SpecEntry('Produzione', '$geminiProduced esemplari'));
    }

    // Designer
    final geminiDesigner = id.designer;
    if (geminiDesigner.isNotEmpty && geminiDesigner != 'N/D') {
      specs.add(_SpecEntry('Design', geminiDesigner));
    }

    return specs
        .map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: _textSecondary,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      s.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // L2 View
  // ---------------------------------------------------------------------------

  Widget _buildL2View() {
    final id = _identification!;
    final vin = _vinResult!;
    final vinSpecs = VinDecoder.getOriginalSpecs(
      vin.rawVin,
      identifiedModel: '${id.brand} ${id.model}',
    );

    return Column(
      children: [
        _buildHeaderBack('Scheda tecnica'),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Car photo 200px
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Image.file(
                    File(_listingImagePath ?? widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand
                      Text(
                        id.brand.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: _textSecondary,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Model
                      Text(
                        id.model,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status badge + VIN
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    size: 14, color: Color(0xFF4CAF50)),
                                SizedBox(width: 4),
                                Text(
                                  'Verificato',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _surfaceLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                vin.rawVin,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  color: _textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // PRODUZIONE section
                      _buildSectionTitle('PRODUZIONE'),
                      _buildSpecRow('Costruttore', vin.manufacturer),
                      _buildSpecRow('Paese', vin.country),
                      if (vin.year != null)
                        _buildSpecRow('Anno', '${vin.year}'),
                      if (vin.serialNumber != null)
                        _buildSpecRow(
                            'Numero di serie', vin.serialNumber!),

                      const _LightDivider(),

                      // SCHEDA RAPIDA (same data as L1, always visible)
                      _buildSectionTitle('SCHEDA RAPIDA'),
                      ..._buildQuickSpecs(),
                      const _LightDivider(),

                      // DATI DA TELAIO section
                      if (vinSpecs.isNotEmpty) ...[
                        _buildSectionTitle('DATI DA TELAIO'),
                        ...vinSpecs.entries
                            .where((e) => e.value != null)
                            .map((e) => _buildSpecRow(
                                _specLabel(e.key), e.value!)),
                        const _LightDivider(),
                      ],

                      // Description
                      if (id.details.isNotEmpty) ...[
                        Text(
                          id.details,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: _textSecondary,
                            height: 1.6,
                          ),
                        ),
                        const _LightDivider(),
                      ],

                      // Market value estimate
                      if (id.marketValueRange.isNotEmpty &&
                          id.marketValueRange != 'N/D')
                        _buildMarketValueCard(id.marketValueRange),

                      // Listing data section
                      if (_listingData != null || _scan?.askingPrice != null) ...[
                        const _LightDivider(),
                        _buildListingDataSection(),
                      ],

                      // Timeline
                      if (id.timeline.isNotEmpty) ...[
                        const _LightDivider(),
                        _buildTimeline(id.timeline),
                      ],

                      // Fun fact
                      if (id.funFact.isNotEmpty && id.funFact != 'N/D') ...[
                        const _LightDivider(),
                        _buildFunFact(id.funFact),
                      ],

                      const _LightDivider(),

                      // Originality report section (auto-generated after VIN decode)
                      if (_generatingReport) ...[
                        const SizedBox(height: 8),
                        _buildGeneratingReportView(),
                        const SizedBox(height: 8),
                      ],

                      if (_originalityReport != null) ...[
                        _buildOriginalitySection(),
                        const _LightDivider(),
                      ],

                      // Condividi scheda button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _shareCar,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _textPrimary,
                            side: const BorderSide(
                                color: _borderColor, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Condividi scheda',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      // Save button if not saved
                      if (_scan == null) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saveToGarage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _textPrimary,
                              foregroundColor: _bgColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Salva nel Garage',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Originality report section (embedded in L2 view)
  // ---------------------------------------------------------------------------

  Widget _buildOriginalitySection() {
    final report = _originalityReport!;
    final score = report.originalityScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ORIGINALIT\u00c0'),

        // Score ring
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _ScoreRingPainter(
                      score: score / 100,
                      filledColor: _textPrimary,
                      emptyColor: _borderColor,
                    ),
                    child: Center(
                      child: Container(
                        width: 116,
                        height: 116,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _bgColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              score.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w300,
                                color: _textPrimary,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'su 100',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _scoreLabel(score),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Conformance checks
        _buildConformRow('Motore', report.engineMatch, _getEngineDesc(report.engineMatch)),
        _buildConformRow('Cambio', report.transmissionMatch, _getTransDesc(report.transmissionMatch)),
        _buildConformRow('Carrozzeria', report.bodyMatch, _getBodyDesc(report.bodyMatch)),

        // Differences
        if (report.notes.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildSectionTitle('DIFFERENZE RILEVATE'),
          ...report.notes.map((note) => _buildDiffBlock(note)),
        ],

        // Conclusion
        if (report.summary.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'IN CONCLUSIONE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  report.summary,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textPrimary,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Disclaimer
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Questo report non sostituisce una perizia tecnica. Per certificazioni ufficiali, rivolgersi al Registro Storico o all\'ASI.',
            style: TextStyle(
              fontSize: 12,
              color: _textTertiary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Generating report loading (inline)
  // ---------------------------------------------------------------------------

  Widget _buildGeneratingReportView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.3 + (_pulseController.value * 0.7),
                child: const Icon(
                  Icons.verified_rounded,
                  color: _textSecondary,
                  size: 48,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: _textPrimary,
              strokeWidth: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Generazione report in corso...',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'L\'AI sta confrontando le specifiche',
            style: TextStyle(color: _textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildListingDataSection() {
    final askingPrice = _listingData?.askingPrice ?? _scan?.askingPrice;
    final mileage = _listingData?.mileage ?? _scan?.mileage;
    final sourceName = _listingData?.sourceName ?? _scan?.sourceName;
    final sourceUrl = _listingData?.sourceUrl ?? _scan?.sourceUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DATI ANNUNCIO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _textSecondary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Column(
            children: [
              if (askingPrice != null && askingPrice.isNotEmpty) ...[
                _buildListingRow('Prezzo richiesto', askingPrice),
                // Show comparison with market estimate if available
                if (_identification != null &&
                    _identification!.marketValueRange.isNotEmpty &&
                    _identification!.marketValueRange != 'N/D')
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      'Stima di mercato: ${_identification!.marketValueRange}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
              if (mileage != null && mileage.isNotEmpty)
                _buildListingRow('Km dichiarati', mileage),
              if (sourceName != null && sourceName.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Provenienza',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sourceName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _textPrimary,
                          ),
                        ),
                        if (sourceUrl != null) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.open_in_new, size: 14, color: _textTertiary),
                        ],
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: _textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _textSecondary,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildMarketValueCard(String marketValue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: Color(0xFF4CAF50), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STIMA DI MERCATO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _textTertiary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  marketValue,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Esemplare in buone condizioni. Stima indicativa.',
                  style: TextStyle(
                    fontSize: 11,
                    color: _textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<String> timeline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('STORIA DEL MODELLO'),
        ...timeline.map((event) {
          final parts = event.split(':');
          final year = parts.isNotEmpty ? parts[0].trim() : '';
          final desc = parts.length > 1 ? parts.sublist(1).join(':').trim() : event;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5, right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _textTertiary.withAlpha(120),
                  ),
                ),
                if (year.isNotEmpty && year.length <= 5) ...[
                  SizedBox(
                    width: 44,
                    child: Text(
                      year,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: _textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ] else
                  Expanded(
                    child: Text(
                      event,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: _textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFunFact(String funFact) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('\ud83d\udca1', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LO SAPEVI?',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8D6E00),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  funFact,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5D4700),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'POTREBBE ANCHE ESSERE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _textSecondary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        ..._alternatives.map((alt) => _buildAlternativeCard(alt)),
      ],
    );
  }

  Widget _buildAlternativeCard(CarIdentification alt) {
    final altPercent = (alt.confidence * 100).round();
    return GestureDetector(
      onTap: () {
        // Analytics (fire-and-forget)
        AnalyticsService().logAlternativeSwapped(
          originalBrand: _identification!.brand,
          swappedToBrand: alt.brand,
        );

        setState(() {
          // Swap: current primary becomes alternative, tapped alt becomes primary
          final currentPrimary = _identification!;
          _alternatives = [
            currentPrimary,
            ..._alternatives.where((a) => a != alt),
          ];
          _identification = alt;
          // Reset VIN/originality data since we changed the identification
          _vinResult = null;
          _originalityReport = null;
          _vinController.clear();
          _currentLevel = 1;
          _showVinInput = false;
          // Refresh car data for new primary
          _carData = _carDataService.findByBrandModel(alt.brand, alt.model);
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${alt.brand} ${alt.model}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$altPercent%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${alt.yearEstimate}${alt.bodyType.isNotEmpty ? ' \u00b7 ${alt.bodyType}' : ''}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: _textSecondary,
              ),
            ),
            if (alt.keyDifference.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                alt.keyDifference,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  color: _textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: _textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConformRow(String field, bool match, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              field,
              style: const TextStyle(
                fontSize: 13,
                color: _textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              desc.isNotEmpty ? desc : (match ? 'Conforme' : 'Non conforme'),
              style: const TextStyle(
                fontSize: 13,
                color: _textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(
              match ? '\u2713' : '\u2717',
              style: TextStyle(
                fontSize: 14,
                color: match ? _textPrimary : _accentRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffBlock(String note) {
    // Determine badge type based on note content
    final noteLower = note.toLowerCase();
    final bool isConform = noteLower.contains('corrisponde') ||
        noteLower.contains('conforme') ||
        noteLower.contains('originale');
    final bool isDiverso = noteLower.contains('diverso') ||
        noteLower.contains('non corrisponde') ||
        noteLower.contains('modificat');

    final String badgeLabel;
    final Color badgeColor;
    final Color badgeBg;

    if (isDiverso) {
      badgeLabel = 'Diverso';
      badgeColor = _accentRed;
      badgeBg = _accentRed.withValues(alpha: 0.08);
    } else if (isConform) {
      badgeLabel = 'Conforme';
      badgeColor = const Color(0xFF2E7D32);
      badgeBg = const Color(0xFF2E7D32).withValues(alpha: 0.08);
    } else {
      badgeLabel = 'Info';
      badgeColor = _textSecondary;
      badgeBg = _surfaceLight;
    }

    // Extract a title: use the first sentence (up to first period) as title
    final periodIdx = note.indexOf('.');
    final title = periodIdx > 0 && periodIdx < 80
        ? note.substring(0, periodIdx + 1)
        : note;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _surfaceLight, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: badgeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (periodIdx > 0 && periodIdx < note.length - 1) ...[
              const SizedBox(height: 12),
              Text(
                note,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B6B6B),
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _specLabel(String key) {
    const labels = {
      'engineType': 'Motore',
      'displacement': 'Cilindrata',
      'fuelSystem': 'Alimentazione',
      'transmission': 'Cambio',
      'bodyStyle': 'Carrozzeria',
      'driveType': 'Trazione',
      'vdsCode': 'Codice VDS',
    };
    return labels[key] ?? key;
  }

  String _scoreLabel(double score) {
    if (score >= 80) return 'Eccellente corrispondenza';
    if (score >= 60) return 'Buona corrispondenza';
    if (score >= 40) return 'Discreta corrispondenza';
    return 'Bassa corrispondenza';
  }


  String _getEngineDesc(bool isMatch) {
    final label = isMatch ? 'conforme' : 'non conforme';
    if (_carData != null && _carData!['engine_code'] != null) {
      return '${_carData!['engine_code']} \u2014 $label';
    }
    return isMatch ? 'Conforme' : 'Non conforme';
  }

  String _getTransDesc(bool isMatch) {
    final label = isMatch ? 'conforme' : 'non conforme';
    if (_carData != null && _carData!['transmission_speeds'] != null) {
      return '${_carData!['transmission_speeds']} marce \u2014 $label';
    }
    return isMatch ? 'Conforme' : 'Non conforme';
  }

  String _getBodyDesc(bool isMatch) {
    final label = isMatch ? 'conforme' : 'non conforme';
    if (_identification != null && _identification!.bodyType.isNotEmpty) {
      return '${_identification!.bodyType} \u2014 $label';
    }
    return isMatch ? 'Conforme' : 'Non conforme';
  }
}

// =============================================================================
// Score Ring Painter
// =============================================================================

class _ScoreRingPainter extends CustomPainter {
  final double score;
  final Color filledColor;
  final Color emptyColor;

  _ScoreRingPainter({
    required this.score,
    required this.filledColor,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // Empty track
    final emptyPaint = Paint()
      ..color = emptyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius - strokeWidth / 2, emptyPaint);

    // Filled arc
    final filledPaint = Paint()
      ..color = filledColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final sweepAngle = 2 * math.pi * score;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, filledPaint);
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}

// =============================================================================
// Reusable private widgets
// =============================================================================

class _SpecEntry {
  final String label;
  final String value;
  const _SpecEntry(this.label, this.value);
}

class _LightDivider extends StatelessWidget {
  const _LightDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Divider(color: Color(0xFFE8E8E6), height: 1),
    );
  }
}
