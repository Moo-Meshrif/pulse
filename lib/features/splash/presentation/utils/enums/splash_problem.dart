import 'package:flutter/widgets.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/l10n.dart';

/// Why the splash could not decide the first screen, and what it shows for it
/// (docs/specs/auth/screens/s13-splash.md).
enum SplashProblem {
  /// The connection was lost or timed out.
  offline,

  /// Anything else the server or the app got wrong; the account is fine.
  cantReach;

  String get icon => switch (this) {
    offline => AppAssets.wifiOff,
    cantReach => AppAssets.cloudAlert,
  };

  String title(BuildContext context) => switch (this) {
    offline => context.l10n.offlineTitle,
    cantReach => context.l10n.cantReachTitle,
  };

  String body(BuildContext context) => switch (this) {
    offline => context.l10n.offlineBody,
    cantReach => context.l10n.cantReachBody,
  };
}
