import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../i18n/strings.g.dart';
import '../services/database_service.dart';
import '../services/telegram_service.dart';
import '../models/car_scan.dart';
import 'results_screen.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  final DatabaseService _db = DatabaseService();
  List<CarScan> _scans = [];
  List<CarScan> _filteredScans = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _filterBrand;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    setState(() => _isLoading = true);
    try {
      final scans = await _db.getScans();
      if (mounted) {
        setState(() {
          _scans = scans;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    var result = _scans.toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((s) =>
              s.brand.toLowerCase().contains(q) ||
              s.model.toLowerCase().contains(q) ||
              s.yearEstimate.toLowerCase().contains(q))
          .toList();
    }
    if (_filterBrand != null) {
      result = result.where((s) => s.brand == _filterBrand).toList();
    }
    _filteredScans = result;
  }

  List<String> get _availableBrands {
    final brands = _scans.map((s) => s.brand).toSet().toList();
    brands.sort();
    return brands;
  }

  String _levelLabel(int level) {
    switch (level) {
      case 1:
        return t.garage.identified;
      case 2:
        return t.garage.verified;
      default:
        return t.garage.identified;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat("d MMM yyyy", 'it_IT').format(date);
  }

  void _showDetailSheet(CarScan scan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DetailSheet(
        scan: scan,
        onDelete: () async {
          Navigator.pop(ctx);
          await _deleteScan(scan);
        },
        onShare: () => _shareScan(scan),
        levelLabel: _levelLabel(scan.level),
        formatDate: _formatDate,
      ),
    );
  }

  Future<void> _deleteScan(CarScan scan) async {
    if (scan.id != null) {
      await _db.deleteScan(scan.id!);
      try {
        final file = File(scan.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      // Telegram notification (fire-and-forget)
      TelegramService().notifyGarageDelete(
        brand: scan.brand,
        model: scan.model,
      );

      _loadScans();
    }
  }

  Future<void> _shareScan(CarScan scan) async {
    // Parse extraData for specs
    Map<String, dynamic> extra = {};
    if (scan.extraData != null && scan.extraData!.isNotEmpty) {
      try {
        extra = jsonDecode(scan.extraData!) as Map<String, dynamic>;
      } catch (_) {}
    }

    final text = StringBuffer();
    text.writeln(scan.brand.toUpperCase());
    text.writeln(scan.model);
    text.writeln('${scan.yearEstimate} \u00b7 ${scan.bodyType}');
    text.writeln(t.garage.shareText.searchReliability(percent: (scan.confidence * 100).toStringAsFixed(0)));
    text.writeln();

    // Specs from extraData
    final disp = extra['displacement'] as String? ?? '';
    final engCode = extra['engine_code'] as String? ?? '';
    if (disp.isNotEmpty && disp != 'N/D') {
      text.writeln(t.garage.shareText.engine(value: '$disp${engCode.isNotEmpty ? ' $engCode' : ''}'));
    }
    final power = extra['power'] as String? ?? '';
    if (power.isNotEmpty && power != 'N/D') text.writeln(t.garage.shareText.power(value: power));
    final tx = extra['transmission'] as String? ?? '';
    final txBrand = extra['transmission_brand'] as String? ?? '';
    if (tx.isNotEmpty && tx != 'N/D') {
      text.writeln(t.garage.shareText.gearbox(value: '$tx${txBrand.isNotEmpty ? ' ($txBrand)' : ''}'));
    }
    final weight = extra['weight'] as String? ?? '';
    final topSpeed = extra['top_speed'] as String? ?? '';
    if (weight.isNotEmpty && weight != 'N/D') {
      text.write(t.garage.shareText.weight(value: weight));
      if (topSpeed.isNotEmpty && topSpeed != 'N/D') text.write(' \u00b7 ${t.garage.shareText.topSpeed(value: topSpeed)}');
      text.writeln();
    }
    final produced = extra['total_produced'] as String? ?? '';
    if (produced.isNotEmpty && produced != 'N/D') text.writeln(t.garage.shareText.production(value: produced));
    final designer = extra['designer'] as String? ?? '';
    if (designer.isNotEmpty && designer != 'N/D') text.writeln(t.garage.shareText.design(value: designer));

    // Market value
    final market = extra['market_value_range'] as String? ?? '';
    if (market.isNotEmpty && market != 'N/D') {
      text.writeln();
      text.writeln(t.garage.shareText.marketEstimate(value: market));
    }

    // VIN
    if (scan.vin != null && scan.vin!.isNotEmpty) {
      text.writeln();
      text.writeln(t.garage.shareText.vin(value: scan.vin!));
    }

    // Originality
    if (scan.originalityScore != null) {
      text.writeln(t.garage.shareText.originality(value: scan.originalityScore!.toStringAsFixed(0)));
    }

    text.writeln();
    text.writeln(t.garage.shareText.footer);

    final file = File(scan.imagePath);
    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(scan.imagePath)],
        text: text.toString(),
      );
    } else {
      await Share.share(text.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: context.colors.textPrimary,
                          strokeWidth: 1.5,
                        ),
                      ),
                    )
                  : _scans.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            if (_scans.length > 3) _buildSearchAndFilter(),
                            Expanded(child: _buildScanList()),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.garage.title,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          if (_scans.isNotEmpty) ...[
            Text(
              _scans.length == 1
                  ? t.garage.scannedCountOne
                  : t.garage.scannedCount(n: _scans.length.toString()),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatsRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final verified = _scans.where((s) => s.level >= 2).length;
    final brands = _scans.map((s) => s.brand).toSet().length;

    // Find most common brand
    String topBrand = '';
    if (_scans.isNotEmpty) {
      final brandCounts = <String, int>{};
      for (final s in _scans) {
        brandCounts[s.brand] = (brandCounts[s.brand] ?? 0) + 1;
      }
      topBrand = brandCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    return Row(
      children: [
        _buildStatChip(Icons.verified_rounded, '$verified',
            verified == 1 ? t.garage.verifiedCountOne : t.garage.verifiedCount(n: verified.toString()), context.colors.success),
        const SizedBox(width: 10),
        _buildStatChip(Icons.local_offer_outlined, '$brands',
            brands == 1 ? t.garage.brandCountOne : t.garage.brandCount(n: brands.toString()), context.colors.textSecondary),
        if (topBrand.isNotEmpty) ...[
          const SizedBox(width: 10),
          _buildStatChip(Icons.emoji_events_outlined, topBrand,
              t.garage.topBrand, context.colors.gold),
        ],
      ],
    );
  }

  Widget _buildStatChip(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.surfaceLight,
                border: Border.all(color: context.colors.border, width: 1),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                color: context.colors.textSecondary,
                size: 44,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              t.garage.empty,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t.garage.emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: t.garage.searchHint,
              hintStyle: TextStyle(color: context.colors.hintText, fontSize: 13),
              prefixIcon: Icon(Icons.search, size: 20, color: context.colors.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _applyFilters();
                        });
                      },
                      child: Icon(Icons.close, size: 18, color: context.colors.textSecondary),
                    )
                  : null,
              filled: true,
              fillColor: context.colors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
          ),
          // Brand filter chips
          if (_availableBrands.length > 1) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(t.garage.all, null),
                  ..._availableBrands.map((b) => _buildFilterChip(b, b)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? brand) {
    final isSelected = _filterBrand == brand;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filterBrand = brand;
            _applyFilters();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.textPrimary : context.colors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? context.colors.background : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanList() {
    return RefreshIndicator(
      onRefresh: _loadScans,
      color: context.colors.textPrimary,
      backgroundColor: context.colors.surfaceCard,
      child: _filteredScans.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  _searchQuery.isNotEmpty || _filterBrand != null
                      ? t.garage.noResults
                      : '',
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              itemCount: _filteredScans.length,
              itemBuilder: (context, index) {
                final scan = _filteredScans[index];
                return _buildScanCard(scan);
              },
            ),
    );
  }

  Widget _buildScanCard(CarScan scan) {
    final imageFile = File(scan.imagePath);
    final hasVin = scan.vin != null && scan.vin!.isNotEmpty;
    final hasOriginality = scan.originalityScore != null;

    return Dismissible(
      key: Key('scan_${scan.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t.garage.deleteTitle),
            content: Text(t.garage.deleteMessage(brand: scan.brand, model: scan.model)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(t.garage.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(t.garage.delete, style: TextStyle(color: context.colors.accentRed)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => _deleteScan(scan),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: context.colors.accentRed.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: context.colors.accentRed,
          size: 28,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(imagePath: scan.imagePath, existingScan: scan),
            ),
          ).then((_) => _loadScans());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.colors.surfaceLight, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 88,
                  height: 66,
                  child: imageFile.existsSync()
                      ? Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _thumbnailPlaceholder(),
                        )
                      : _thumbnailPlaceholder(),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    Text(
                      scan.brand.toUpperCase(),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    // Model
                    Text(
                      scan.model,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Detail
                    Text(
                      hasVin
                          ? '${scan.yearEstimate} \u00b7 ${scan.vin}'
                          : '${scan.yearEstimate} \u00b7 ${t.garage.identificationOnly}',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Originality score
                    if (hasOriginality) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Mini score ring
                          _MiniScoreRing(
                              score: scan.originalityScore! / 100),
                          const SizedBox(width: 6),
                          Text(
                            t.garage.originalityScore(score: scan.originalityScore!.toStringAsFixed(0)),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Level dots
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          scan.level >= 2
                              ? Icons.verified_rounded
                              : Icons.auto_awesome,
                          size: 14,
                          color: scan.level >= 2
                              ? context.colors.success
                              : context.colors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _levelLabel(scan.level),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: scan.level >= 2
                                ? context.colors.success
                                : context.colors.textTertiary,
                          ),
                        ),
                      ],
                    ),

                    // Marketplace source badge
                    if (scan.sourceName != null && scan.sourceName!.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.link,
                            size: 12,
                            color: context.colors.teal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            scan.sourceName!,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.teal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Action text for incomplete scans
                    if (scan.level < 2) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          final imageFile = File(scan.imagePath);
                          if (imageFile.existsSync()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResultScreen(imagePath: scan.imagePath, existingScan: scan),
                              ),
                            ).then((_) => _loadScans());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t.garage.photoUnavailable),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              '+',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: context.colors.accentRed,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              t.garage.addVin,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (scan.level == 2 && !hasOriginality) ...[
                      // Edge case: old L2 scans without originality report
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          final imageFile = File(scan.imagePath);
                          if (imageFile.existsSync()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResultScreen(imagePath: scan.imagePath, existingScan: scan),
                              ),
                            ).then((_) => _loadScans());
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              '+',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: context.colors.accentRed,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              t.garage.verifyOriginality,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: context.colors.surfaceLight,
      child: Icon(
        Icons.directions_car_outlined,
        color: context.colors.textTertiary,
        size: 28,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini score ring for garage cards
// ---------------------------------------------------------------------------

class _MiniScoreRing extends StatelessWidget {
  final double score;
  const _MiniScoreRing({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              value: score,
              strokeWidth: 2.5,
              backgroundColor: context.colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                  context.colors.textPrimary),
            ),
          ),
          Text(
            (score * 100).toStringAsFixed(0),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail bottom sheet
// ---------------------------------------------------------------------------

class _DetailSheet extends StatelessWidget {
  final CarScan scan;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final String levelLabel;
  final String Function(DateTime) formatDate;

  const _DetailSheet({
    required this.scan,
    required this.onDelete,
    required this.onShare,
    required this.levelLabel,
    required this.formatDate,
  });

  // Parse extraData JSON once
  Map<String, dynamic> get _extra {
    if (scan.extraData == null || scan.extraData!.isEmpty) return {};
    try {
      return jsonDecode(scan.extraData!) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  List<_GarageSpecEntry> _buildSpecEntries(Map<String, dynamic> extra) {
    final specs = <_GarageSpecEntry>[];

    final displacement = extra['displacement'] as String? ?? '';
    final engineCode = extra['engine_code'] as String? ?? '';
    if (displacement.isNotEmpty || engineCode.isNotEmpty) {
      final val = displacement.isNotEmpty && engineCode.isNotEmpty
          ? '$displacement $engineCode'
          : displacement.isNotEmpty ? displacement : engineCode;
      specs.add(_GarageSpecEntry(t.garage.specs.engine, val));
    }

    final power = extra['power'] as String? ?? '';
    if (power.isNotEmpty && power != 'N/D') {
      specs.add(_GarageSpecEntry(t.garage.specs.power, power));
    }

    final transmission = extra['transmission'] as String? ?? '';
    final txBrand = extra['transmission_brand'] as String? ?? '';
    if (transmission.isNotEmpty && transmission != 'N/D') {
      final val = txBrand.isNotEmpty && !transmission.contains(txBrand)
          ? '$transmission ($txBrand)'
          : transmission;
      specs.add(_GarageSpecEntry(t.garage.specs.gearbox, val));
    }

    final weight = extra['weight'] as String? ?? '';
    if (weight.isNotEmpty && weight != 'N/D') {
      specs.add(_GarageSpecEntry(t.garage.specs.weight, weight));
    }

    final topSpeed = extra['top_speed'] as String? ?? '';
    if (topSpeed.isNotEmpty && topSpeed != 'N/D') {
      specs.add(_GarageSpecEntry(t.garage.specs.topSpeed, topSpeed));
    }

    final produced = extra['total_produced'] as String? ?? '';
    if (produced.isNotEmpty && produced != 'N/D') {
      specs.add(_GarageSpecEntry(t.garage.specs.production, t.garage.specs.productionValue(n: produced)));
    }

    final designer = extra['designer'] as String? ?? '';
    if (designer.isNotEmpty && designer != 'N/D') {
      specs.add(_GarageSpecEntry(t.garage.specs.design, designer));
    }

    return specs;
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = File(scan.imagePath);
    final confidencePercent = (scan.confidence * 100).toStringAsFixed(0);
    final extra = _extra;
    final specEntries = _buildSpecEntries(extra);
    final marketValue = extra['market_value_range'] as String? ?? '';
    final timeline = (extra['timeline'] as List?)
        ?.map((e) => e.toString())
        .toList() ?? [];
    final funFact = extra['fun_fact'] as String? ?? '';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Full photo
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: imageFile.existsSync()
                      ? Image.file(imageFile, fit: BoxFit.cover)
                      : Container(
                          color: context.colors.surfaceLight,
                          child: Icon(
                            Icons.directions_car_outlined,
                            color: context.colors.textSecondary,
                            size: 64,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Brand + Model
              Text(
                scan.brand.toUpperCase(),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scan.model,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${scan.yearEstimate}  \u00b7  ${scan.bodyType}  \u00b7  ${scan.color}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${t.garage.confidence} $confidencePercent%  \u00b7  ${formatDate(scan.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textTertiary,
                ),
              ),

              // Marketplace listing data
              if (scan.sourceName != null && scan.sourceName!.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: context.colors.border, height: 1),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.link, size: 16, color: context.colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            t.garage.from(source: scan.sourceName!.toUpperCase()),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.colors.teal,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      if (scan.askingPrice != null && scan.askingPrice!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.garage.askingPrice,
                              style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
                            ),
                            Text(
                              scan.askingPrice!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (scan.mileage != null && scan.mileage!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.garage.mileage,
                              style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
                            ),
                            Text(
                              scan.mileage!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Scheda Rapida specs
              if (specEntries.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: context.colors.border, height: 1),
                ),
                Text(
                  t.garage.quickSpecs,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                ...specEntries.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          s.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                )),
              ],

              // Description
              if (scan.details.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: context.colors.border, height: 1),
                ),
                Text(
                  scan.details,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: context.colors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],

              // Market value estimate
              if (marketValue.isNotEmpty && marketValue != 'N/D') ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: context.colors.border, height: 1),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceWarm,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, color: context.colors.success, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.garage.marketEstimate,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: context.colors.textTertiary,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              marketValue,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.garage.marketDisclaimer,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.colors.textTertiary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Timeline / Storia del Modello
              if (timeline.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: context.colors.border, height: 1),
                ),
                Text(
                  t.garage.modelHistory,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                ...timeline.map((event) {
                  final parts = event.split(':');
                  final year = parts.isNotEmpty ? parts[0].trim() : '';
                  final desc = parts.length > 1
                      ? parts.sublist(1).join(':').trim()
                      : event;
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
                            color: context.colors.textSecondary.withAlpha(120),
                          ),
                        ),
                        if (year.isNotEmpty && year.length <= 5) ...[
                          SizedBox(
                            width: 44,
                            child: Text(
                              year,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              desc,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: context.colors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ] else
                          Expanded(
                            child: Text(
                              event,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: context.colors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],

              // Fun fact / Lo Sapevi?
              if (funFact.isNotEmpty && funFact != 'N/D') ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: context.colors.border, height: 1),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.colors.goldBg,
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
                            Text(
                              t.garage.funFact,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: context.colors.goldDark,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              funFact,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: context.colors.goldDarker,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // VIN section
              if (scan.vin != null && scan.vin!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'VIN',
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          scan.vin!,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 13,
                            fontFamily: 'monospace',
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Originality score
              if (scan.originalityScore != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                value: scan.originalityScore! / 100,
                                strokeWidth: 3,
                                backgroundColor: context.colors.border,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        context.colors.textPrimary),
                              ),
                            ),
                            Text(
                              '${scan.originalityScore!.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.garage.originalityLabel,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _originalityLabel(scan.originalityScore!),
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Originality report
              if (scan.originalityReport != null &&
                  scan.originalityReport!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.garage.originalityReport,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        scan.originalityReport!,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Condividi button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined, size: 20),
                  label: Text(
                    t.garage.share,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.textPrimary,
                    foregroundColor: context.colors.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Elimina button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: onDelete,
                  child: Text(
                    t.garage.deleteAction,
                    style: TextStyle(
                      color: context.colors.accentRed,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _originalityLabel(double score) {
    if (score >= 80) return t.garage.originalityExcellent;
    if (score >= 60) return t.garage.originalityGood;
    if (score >= 40) return t.garage.originalityFair;
    return t.garage.originalityLow;
  }
}

class _GarageSpecEntry {
  final String label;
  final String value;
  const _GarageSpecEntry(this.label, this.value);
}
