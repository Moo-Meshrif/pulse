import 'package:flutter/material.dart';

import 'app_colors.dart';

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
    );
  }
}
