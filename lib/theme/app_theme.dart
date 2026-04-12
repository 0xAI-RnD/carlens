import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.light.background,
    colorScheme: ColorScheme.light(
      primary: AppColors.light.textPrimary,
      secondary: AppColors.light.textPrimary,
      surface: AppColors.light.surfaceCard,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.light.background,
      elevation: 0,
      centerTitle: true,
      foregroundColor: AppColors.light.textPrimary,
    ),
    cardTheme: CardThemeData(
      color: AppColors.light.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.light.background,
      selectedItemColor: AppColors.light.textPrimary,
      unselectedItemColor: AppColors.light.textSecondary,
    ),
    extensions: const [AppColors.light],
  );
}
