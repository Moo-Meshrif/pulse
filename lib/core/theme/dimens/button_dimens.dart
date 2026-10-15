import '../app_scale.dart';

/// Pill buttons of the auth flow: primary states, outline, soft, danger
/// (docs/specs/auth/01-design-tokens.md "button states", "outline pill button").
abstract final class ButtonDimens {
  /// Primary button disabled fill: `primary` @ 40%.
  static const double disabledOpacity = 0.4;

  /// The heartbeat line in a loading button; its frame is 88/184 as tall, so it fits the 48 pill too.
  static double get loaderWidth => AppScale.scale(72);
  static const double outlineBorderWidth = 1; // unscaled: hairline
  /// Outline pills have no fixed height: vertical padding 15 (+ 16/700 label).
  static double get outlineVerticalPadding => AppScale.scale(15);

  /// Soft and danger pills (dialog actions, S9, S10).
  static const double pillHeight = 48; // tap target: fixed
}
