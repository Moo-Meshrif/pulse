import 'package:flutter/widgets.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';

/// The looks of a [PillButton] (docs/specs/auth/02-components.md C4). Each variant owns its facts
/// (sizing) and its theme colors.
enum PillButtonVariant {
  /// White with a 1 px `border` outline; no fixed height (vertical padding 15).
  outline(fixedHeight: false),

  /// `background` fill, 48 high: dialog cancel actions.
  soft(fixedHeight: true),

  /// `danger` fill with a white label, 48 high: the confirm action of a destructive dialog.
  danger(fixedHeight: true);

  const PillButtonVariant({required this.fixedHeight});

  /// Fixed 48 high, or sized by its vertical padding.
  final bool fixedHeight;

  double? get height => fixedHeight ? AuthButtonDimens.pillHeight : null;

  double get verticalPadding =>
      fixedHeight ? 0 : AuthButtonDimens.outlineVerticalPadding;

  Color fill(BuildContext context) => switch (this) {
    PillButtonVariant.outline => context.appColors.surface,
    PillButtonVariant.soft => context.appColors.background,
    PillButtonVariant.danger => context.appColors.danger,
  };

  Color foreground(BuildContext context) => switch (this) {
    PillButtonVariant.outline => context.appColors.textPrimary,
    PillButtonVariant.soft => context.appColors.textPrimary,
    PillButtonVariant.danger => context.appColors.textOnPrimary,
  };

  /// Only the outline variant has a border.
  Color? border(BuildContext context) => switch (this) {
    PillButtonVariant.outline => context.appColors.border,
    PillButtonVariant.soft => null,
    PillButtonVariant.danger => null,
  };
}
