import 'package:flutter/widgets.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/l10n.dart';

/// The four tabs of the main shell, in nav order (the Create button sits between Shorts and Chat and is
/// not a tab).
enum MainTab {
  home,
  shorts,
  chat,
  profile;

  String get icon => switch (this) {
    home => AppAssets.home,
    shorts => AppAssets.shorts,
    chat => AppAssets.chat,
    profile => AppAssets.profile,
  };

  /// The filled variant shown while the tab is selected.
  String get activeIcon => switch (this) {
    home => AppAssets.homeFilled,
    shorts => AppAssets.shortsFilled,
    chat => AppAssets.chatFilled,
    profile => AppAssets.profileFilled,
  };

  /// Screen-reader label: the bar has no visible text.
  String l10n(BuildContext context) => switch (this) {
    home => context.l10n.navHome,
    shorts => context.l10n.navShorts,
    chat => context.l10n.navChat,
    profile => context.l10n.navProfile,
  };
}
