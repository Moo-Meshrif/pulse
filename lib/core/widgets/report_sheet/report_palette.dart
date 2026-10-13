import 'package:flutter/material.dart';

import '../../enums/sheet_tone.dart';
import '../../extensions/context_extensions.dart';
import '../../theme/app_dimens.dart';

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
    final c = context.appColors;
    return switch (tone) {
      SheetTone.dark => ReportPalette._(
        title: c.storyOnDark,
        body: c.storyOnDark.withValues(alpha: StoryOpacity.helper),
        group: c.storySheetRow,
        separator: c.storyOnDark.withValues(alpha: StoryOpacity.separator),
        chevron: c.storyOnDark.withValues(alpha: StoryOpacity.chevron),
        danger: c.dangerOnDark,
        fieldBorder: c.storyOnDark.withValues(alpha: StoryOpacity.fieldBorder),
        fieldFocus: c.storyOnDark,
        success: c.storySuccess,
        closeFill: c.storyOnDark.withValues(alpha: StoryOpacity.secondaryFill),
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
