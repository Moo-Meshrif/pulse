import 'package:flutter/material.dart';

import '../../enums/sheet_tone.dart';
import '../../extensions/context_extensions.dart';
import '../../theme/dimens/app_dimens.dart';

/// The colors of the report sheet for a [SheetTone]: the story screens use the dark ones, the post feature
/// the light ones.
class ReportPalette {
  const ReportPalette._({
    required this.title,
    required this.body,
    required this.group,
    required this.separator,
    required this.chevron,
    required this.danger,
    required this.fieldBorder,
    required this.fieldFocus,
    required this.success,
    required this.closeFill,
  });

  factory ReportPalette.of(BuildContext context, SheetTone tone) {
    final colors = context.appColors;
    final c = colors;
    return switch (tone) {
      SheetTone.dark => ReportPalette._(
        title: colors.onDark,
        body: colors.onDark.withValues(alpha: DarkOpacity.helper),
        group: colors.darkSurfaceRow,
        separator: colors.onDark.withValues(alpha: DarkOpacity.separator),
        chevron: colors.onDark.withValues(alpha: DarkOpacity.chevron),
        danger: colors.dangerOnDark,
        fieldBorder: colors.onDark.withValues(alpha: DarkOpacity.fieldBorder),
        fieldFocus: colors.onDark,
        success: colors.successOnDark,
        closeFill: colors.onDark.withValues(alpha: DarkOpacity.secondaryFill),
      ),
      SheetTone.light => ReportPalette._(
        title: c.textPrimary,
        body: c.textSecondary,
        group: c.surfaceMuted,
        separator: c.divider,
        chevron: c.textSecondary,
        danger: c.danger,
        fieldBorder: c.border,
        fieldFocus: c.primary,
        success: c.primary,
        closeFill: c.background,
      ),
    };
  }

  final Color title;
  final Color body;
  final Color group;
  final Color separator;
  final Color chevron;
  final Color danger;
  final Color fieldBorder;
  final Color fieldFocus;
  final Color success;
  final Color closeFill;
}
