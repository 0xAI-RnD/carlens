import 'dart:io';
import 'package:flutter/material.dart';
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
    if (mounted) setState(() => _isLoading = true);
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
          ? ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      _searchQuery.isNotEmpty || _filterBrand != null
                          ? t.garage.noResults
                          : '',
                      style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
                    ),
                  ),
                ),
              ],
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
              builder: (_) => ResultScreen(imagePath: scan.imagePath, existingScan: scan, scanSource: 'garage'),
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
                          errorBuilder: (_, e, st) =>
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
                                builder: (_) => ResultScreen(imagePath: scan.imagePath, existingScan: scan, scanSource: 'garage'),
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
                                builder: (_) => ResultScreen(imagePath: scan.imagePath, existingScan: scan, scanSource: 'garage'),
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

