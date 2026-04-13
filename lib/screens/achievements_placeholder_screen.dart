import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../i18n/strings.g.dart';
import '../theme/app_colors.dart';
import '../models/achievement.dart';
import '../services/database_service.dart';

class AchievementsPlaceholderScreen extends StatefulWidget {
  const AchievementsPlaceholderScreen({super.key});

  @override
  State<AchievementsPlaceholderScreen> createState() =>
      _AchievementsPlaceholderScreenState();
}

class _AchievementsPlaceholderScreenState
    extends State<AchievementsPlaceholderScreen> {
  List<Achievement>? _achievements;
  int _scanCount = 0;
  int _brandCount = 0;
  int _eraCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseService();
    final achievements = await db.getAchievements();
    final scanCount = await db.getScanCount();
    final brandCount = await db.getDistinctBrandCount();
    final eraCount = await db.getDistinctEraCount();

    if (mounted) {
      setState(() {
        _achievements = achievements;
        _scanCount = scanCount;
        _brandCount = brandCount;
        _eraCount = eraCount;
      });
    }
  }

  int _currentValueForCategory(String category) {
    return switch (category) {
      'scans' => _scanCount,
      'brands' => _brandCount,
      'eras' => _eraCount,
      _ => 0,
    };
  }

  String _categoryName(String category) {
    return switch (category) {
      'scans' => t.achievements.scans,
      'brands' => t.achievements.brands,
      'eras' => t.achievements.eras,
      _ => '',
    };
  }

  String _categoryDesc(String category) {
    return switch (category) {
      'scans' => t.achievements.scansDesc,
      'brands' => t.achievements.brandsDesc,
      'eras' => t.achievements.erasDesc,
      _ => '',
    };
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'scans' => Icons.camera_alt,
      'brands' => Icons.directions_car,
      'eras' => Icons.history,
      _ => Icons.emoji_events,
    };
  }

  String _badgeName(String category) {
    return switch (category) {
      'scans' => t.achievements.scansBadgeName,
      'brands' => t.achievements.brandsBadgeName,
      'eras' => t.achievements.erasBadgeName,
      _ => '',
    };
  }

  String _tierName(String tier) {
    return switch (tier) {
      'base' => t.achievements.base,
      'bronze' => t.achievements.bronze,
      'silver' => t.achievements.silver,
      'gold' => t.achievements.gold,
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: _achievements == null
            ? Center(
                child: CircularProgressIndicator(
                  color: context.colors.textPrimary,
                  strokeWidth: 1.5,
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final categories = ['scans', 'brands', 'eras'];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        // Header
        Text(
          t.achievements.title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        // Category sections
        for (final category in categories) ...[
          _buildCategorySection(category),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildCategorySection(String category) {
    final categoryAchievements = _achievements!
        .where((a) => a.category == category)
        .toList()
      ..sort((a, b) => a.threshold.compareTo(b.threshold));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              _categoryIcon(category),
              size: 22,
              color: context.colors.teal,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _categoryName(category),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  _categoryDesc(category),
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Badge cards
        for (final achievement in categoryAchievements)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildBadgeCard(achievement),
          ),
      ],
    );
  }

  Widget _buildBadgeCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final isGold = achievement.tier == 'gold';
    final currentValue = _currentValueForCategory(achievement.category);

    final bgColor = isUnlocked
        ? (isGold ? context.colors.goldBg : context.colors.surfaceCard)
        : context.colors.surfaceLight.withValues(alpha: 0.5);

    final borderColor = isUnlocked && isGold
        ? context.colors.gold
        : context.colors.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Icon
          SizedBox(
            width: 40,
            child: isUnlocked
                ? Icon(
                    _categoryIcon(achievement.category),
                    size: 24,
                    color: isGold
                        ? context.colors.gold
                        : context.colors.teal,
                  )
                : Icon(
                    Icons.lock_outline,
                    size: 24,
                    color: context.colors.textTertiary,
                  ),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_badgeName(achievement.category)} ${_tierName(achievement.tier)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? (isGold
                            ? context.colors.gold
                            : context.colors.textPrimary)
                        : context.colors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                if (isUnlocked)
                  Text(
                    t.achievements.unlockedOn(
                      date: DateFormat('dd MMM yyyy', 'it')
                          .format(achievement.unlockedAt!),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  )
                else ...[
                  Text(
                    t.achievements.progress(
                      current: currentValue.toString(),
                      target: achievement.threshold.toString(),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (currentValue / achievement.threshold)
                          .clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: context.colors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.gold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
