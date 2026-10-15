import 'package:flutter/material.dart';

import 'colors/app_colors.dart';
import 'dimens/app_dimens.dart';

abstract final class AppTheme {
  /// Light only for now. A dark theme needs dark tokens first (docs/specs/_theme/colors.md).
  static ThemeData get light => _build(AppColors.light);

  static ThemeData _build(AppColors c) {
    final scheme = ColorScheme.light(
      primary: c.primary,
      onPrimary: c.textOnPrimary,
      primaryContainer: c.primarySoft,
      onPrimaryContainer: c.primary,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerHighest: c.segmentTrack,
      outline: c.border,
      outlineVariant: c.divider,
      error: c.danger,
      onError: c.textOnPrimary,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      // Latin text uses Noto Sans; Arabic glyphs fall back to Noto Sans Arabic.
      fontFamily: 'NotoSans',
      fontFamilyFallback: const ['NotoSansArabic'],
      extensions: [c],
      // Defaults of the Material widgets the app uses, so a screen only sets what differs.
      dividerTheme: DividerThemeData(
        color: c.divider,
        space: 1, // unscaled: hairline
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(c.surface),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? c.primary : c.switchOff,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: c.primary),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(AppSizes.tapTarget, AppSizes.tapTarget),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
    );
  }
}
