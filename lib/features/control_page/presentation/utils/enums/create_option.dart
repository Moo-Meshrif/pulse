import 'package:flutter/widgets.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_routes.dart';

/// What the Create sheet offers. Each option opens its own full-screen flow.
enum CreateOption {
  post,
  short;

  /// The full-screen route this option opens.
  String get route => switch (this) {
    post => AppRoutes.createPost,
    short => AppRoutes.createShort,
  };

  String get icon => switch (this) {
    post => AppAssets.createPost,
    short => AppAssets.createShort,
  };

  String title(BuildContext context) => switch (this) {
    post => context.l10n.createPost,
    short => context.l10n.createShort,
  };

  String subtitle(BuildContext context) => switch (this) {
    post => context.l10n.createPostSub,
    short => context.l10n.createShortSub,
  };
}
