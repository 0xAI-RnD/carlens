import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color surfaceLight;
  final Color surfaceCard;
  final Color accentRed;
  final Color success;
  final Color successDark;
  final Color teal;
  final Color gold;
  final Color goldBg;
  final Color goldDark;
  final Color goldDarker;
  final Color hintText;
  final Color subtleText;
  final Color surfaceWarm;
  final Color surfaceTeal;

  const AppColors({
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.surfaceLight,
    required this.surfaceCard,
    required this.accentRed,
    required this.success,
    required this.successDark,
    required this.teal,
    required this.gold,
    required this.goldBg,
    required this.goldDark,
    required this.goldDarker,
    required this.hintText,
    required this.subtleText,
    required this.surfaceWarm,
    required this.surfaceTeal,
  });

  static const light = AppColors(
    background: Color(0xFFFAFAF8),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF8C8C8C),
    textTertiary: Color(0xFFB0B0B0),
    border: Color(0xFFE8E8E6),
    surfaceLight: Color(0xFFF0F0EE),
    surfaceCard: Color(0xFFFFFFFF),
    accentRed: Color(0xFFC4342D),
    success: Color(0xFF4CAF50),
    successDark: Color(0xFF2E7D32),
    teal: Color(0xFF5C8A8A),
    gold: Color(0xFFE6A817),
    goldBg: Color(0xFFFFF8E1),
    goldDark: Color(0xFF8D6E00),
    goldDarker: Color(0xFF5D4700),
    hintText: Color(0xFFCCCCCC),
    subtleText: Color(0xFF6B6B6B),
    surfaceWarm: Color(0xFFF5F5F0),
    surfaceTeal: Color(0xFFF0F5F5),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? surfaceLight,
    Color? surfaceCard,
    Color? accentRed,
    Color? success,
    Color? successDark,
    Color? teal,
    Color? gold,
    Color? goldBg,
    Color? goldDark,
    Color? goldDarker,
    Color? hintText,
    Color? subtleText,
    Color? surfaceWarm,
    Color? surfaceTeal,
  }) {
    return AppColors(
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      accentRed: accentRed ?? this.accentRed,
      success: success ?? this.success,
      successDark: successDark ?? this.successDark,
      teal: teal ?? this.teal,
      gold: gold ?? this.gold,
      goldBg: goldBg ?? this.goldBg,
      goldDark: goldDark ?? this.goldDark,
      goldDarker: goldDarker ?? this.goldDarker,
      hintText: hintText ?? this.hintText,
      subtleText: subtleText ?? this.subtleText,
      surfaceWarm: surfaceWarm ?? this.surfaceWarm,
      surfaceTeal: surfaceTeal ?? this.surfaceTeal,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
      success: Color.lerp(success, other.success, t)!,
      successDark: Color.lerp(successDark, other.successDark, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldBg: Color.lerp(goldBg, other.goldBg, t)!,
      goldDark: Color.lerp(goldDark, other.goldDark, t)!,
      goldDarker: Color.lerp(goldDarker, other.goldDarker, t)!,
      hintText: Color.lerp(hintText, other.hintText, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      surfaceWarm: Color.lerp(surfaceWarm, other.surfaceWarm, t)!,
      surfaceTeal: Color.lerp(surfaceTeal, other.surfaceTeal, t)!,
    );
  }
}

extension AppColorsExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
