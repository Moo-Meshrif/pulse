import 'package:flutter/widgets.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/l10n.dart';

/// Why the splash could not decide the first screen, and what it shows for it
/// (docs/specs/auth/screens/s13-splash.md).
enum SplashProblem {
  /// No Wi-Fi and no mobile data.
  offline,

  /// A network is on, but it reaches nothing.
  noInternet,

  /// The backend answers too slowly.
  weakConnection,

  /// Anything else the server or the app got wrong; the account is fine.
  cantReach;

  String get icon => switch (this) {
    offline => AppAssets.wifiOff,
    noInternet || weakConnection || cantReach => AppAssets.cloudAlert,
  };

  String title(BuildContext context) => switch (this) {
    offline => context.l10n.offlineTitle,
    noInternet => context.l10n.noInternetTitle,
    weakConnection => context.l10n.weakConnectionTitle,
    cantReach => context.l10n.cantReachTitle,
  };

  String body(BuildContext context) => switch (this) {
    offline => context.l10n.offlineBody,
    noInternet => context.l10n.noInternetBody,
    weakConnection => context.l10n.weakConnectionBody,
    cantReach => context.l10n.cantReachBody,
  };
}
