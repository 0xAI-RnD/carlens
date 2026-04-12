import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carlens/theme/app_colors.dart';

void main() {
  group('AppColors.light hex values', () {
    test('background is 0xFFFAFAF8', () {
      expect(AppColors.light.background, const Color(0xFFFAFAF8));
    });

    test('textPrimary is 0xFF1A1A1A', () {
      expect(AppColors.light.textPrimary, const Color(0xFF1A1A1A));
    });

    test('textSecondary is 0xFF8C8C8C', () {
      expect(AppColors.light.textSecondary, const Color(0xFF8C8C8C));
    });

    test('textTertiary is 0xFFB0B0B0', () {
      expect(AppColors.light.textTertiary, const Color(0xFFB0B0B0));
    });

    test('border is 0xFFE8E8E6', () {
      expect(AppColors.light.border, const Color(0xFFE8E8E6));
    });

    test('surfaceLight is 0xFFF0F0EE', () {
      expect(AppColors.light.surfaceLight, const Color(0xFFF0F0EE));
    });

    test('surfaceCard is 0xFFFFFFFF', () {
      expect(AppColors.light.surfaceCard, const Color(0xFFFFFFFF));
    });

    test('accentRed is 0xFFC4342D', () {
      expect(AppColors.light.accentRed, const Color(0xFFC4342D));
    });

    test('success is 0xFF4CAF50', () {
      expect(AppColors.light.success, const Color(0xFF4CAF50));
    });

    test('successDark is 0xFF2E7D32', () {
      expect(AppColors.light.successDark, const Color(0xFF2E7D32));
    });

    test('teal is 0xFF5C8A8A', () {
      expect(AppColors.light.teal, const Color(0xFF5C8A8A));
    });

    test('gold is 0xFFE6A817', () {
      expect(AppColors.light.gold, const Color(0xFFE6A817));
    });

    test('goldBg is 0xFFFFF8E1', () {
      expect(AppColors.light.goldBg, const Color(0xFFFFF8E1));
    });

    test('goldDark is 0xFF8D6E00', () {
      expect(AppColors.light.goldDark, const Color(0xFF8D6E00));
    });

    test('goldDarker is 0xFF5D4700', () {
      expect(AppColors.light.goldDarker, const Color(0xFF5D4700));
    });

    test('hintText is 0xFFCCCCCC', () {
      expect(AppColors.light.hintText, const Color(0xFFCCCCCC));
    });

    test('subtleText is 0xFF6B6B6B', () {
      expect(AppColors.light.subtleText, const Color(0xFF6B6B6B));
    });

    test('surfaceWarm is 0xFFF5F5F0', () {
      expect(AppColors.light.surfaceWarm, const Color(0xFFF5F5F0));
    });

    test('surfaceTeal is 0xFFF0F5F5', () {
      expect(AppColors.light.surfaceTeal, const Color(0xFFF0F5F5));
    });
  });

  group('AppColors.copyWith', () {
    test('with no args returns identical values', () {
      final copy = AppColors.light.copyWith();
      expect(copy.background, AppColors.light.background);
      expect(copy.textPrimary, AppColors.light.textPrimary);
      expect(copy.textSecondary, AppColors.light.textSecondary);
      expect(copy.textTertiary, AppColors.light.textTertiary);
      expect(copy.border, AppColors.light.border);
      expect(copy.surfaceLight, AppColors.light.surfaceLight);
      expect(copy.surfaceCard, AppColors.light.surfaceCard);
      expect(copy.accentRed, AppColors.light.accentRed);
      expect(copy.success, AppColors.light.success);
      expect(copy.successDark, AppColors.light.successDark);
      expect(copy.teal, AppColors.light.teal);
      expect(copy.gold, AppColors.light.gold);
      expect(copy.goldBg, AppColors.light.goldBg);
      expect(copy.goldDark, AppColors.light.goldDark);
      expect(copy.goldDarker, AppColors.light.goldDarker);
      expect(copy.hintText, AppColors.light.hintText);
      expect(copy.subtleText, AppColors.light.subtleText);
      expect(copy.surfaceWarm, AppColors.light.surfaceWarm);
      expect(copy.surfaceTeal, AppColors.light.surfaceTeal);
    });

    test('with one arg changes only that value', () {
      const newColor = Color(0xFFFF0000);
      final copy = AppColors.light.copyWith(background: newColor);
      expect(copy.background, newColor);
      expect(copy.textPrimary, AppColors.light.textPrimary);
      expect(copy.accentRed, AppColors.light.accentRed);
      expect(copy.surfaceTeal, AppColors.light.surfaceTeal);
    });
  });

  group('AppColors.lerp', () {
    final target = AppColors.light.copyWith(
      background: const Color(0xFF000000),
      textPrimary: const Color(0xFFFFFFFF),
    );

    test('at t=0 returns source values', () {
      final result = AppColors.light.lerp(target, 0);
      expect(result.background, AppColors.light.background);
      expect(result.textPrimary, AppColors.light.textPrimary);
    });

    test('at t=1 returns target values', () {
      final result = AppColors.light.lerp(target, 1);
      expect(result.background, target.background);
      expect(result.textPrimary, target.textPrimary);
    });

    test('with null other returns this', () {
      final result = AppColors.light.lerp(null, 0.5);
      expect(result.background, AppColors.light.background);
    });
  });

  group('BuildContext.colors extension', () {
    testWidgets('returns AppColors from theme', (tester) async {
      late AppColors colorsFromContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [AppColors.light],
          ),
          home: Builder(
            builder: (context) {
              colorsFromContext = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(colorsFromContext.background, AppColors.light.background);
      expect(colorsFromContext.textPrimary, AppColors.light.textPrimary);
      expect(colorsFromContext.accentRed, AppColors.light.accentRed);
    });
  });
}
