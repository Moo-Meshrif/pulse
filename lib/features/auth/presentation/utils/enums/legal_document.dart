import 'package:flutter/widgets.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_routes.dart';

/// The legal pages the sign-up checkbox links to.
enum LegalDocument {
  terms(route: AppRoutes.terms),
  privacy(route: AppRoutes.privacy);

  const LegalDocument({required this.route});

  /// The route that opens the page (`AppNavigator.push(context, document.route)`).
  final String route;

  String l10n(BuildContext context) => switch (this) {
    LegalDocument.terms => context.l10n.terms,
    LegalDocument.privacy => context.l10n.privacyPolicy,
  };
}
