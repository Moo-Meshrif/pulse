import 'package:flutter/material.dart';

import '../app_scale.dart';

/// Shared dialog shell and its content (docs/specs/auth/01-design-tokens.md, 02-components.md C14).
abstract final class DialogDimens {
  /// Backdrop blur under the scrim (sigma x and y). A blur radius is not a layout size: not scaled.
  static const double backdropBlurSigma = 12;

  /// The card is `screen width - 2 * margin`, at most [maxWidth].
  static double get margin => AppScale.scale(24);
  static double get maxWidth => AppScale.scale(342);
  static EdgeInsets get padding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(24),
    vertical: AppScale.scale(28),
  );
  static double get iconCircle => AppScale.scale(56);
  static double get icon => AppScale.scale(24);
  static double get iconToTitleGap => AppScale.scale(16);
  static double get titleToMessageGap => AppScale.scale(8);
  static double get messageToActionsGap => AppScale.scale(24);
  static double get actionGap => AppScale.scale(12);
  static double get stackedActionGap => AppScale.scale(8);
  static const Duration transition = Duration(milliseconds: 180);
  static const double enterScale = 0.96;
}
