import 'package:flutter/widgets.dart';

import '../extensions/l10n.dart';
import '../router/app_routes.dart';

/// The legal pages: the two the sign-up checkbox links to, and the rest of "Terms & policies".
enum LegalDocument {
  terms(route: AppRoutes.terms, wire: 'terms'),
  privacy(route: AppRoutes.privacy, wire: 'privacy'),
  communityGuidelines(route: AppRoutes.communityGuidelines, wire: 'community'),
  cookiePolicy(route: AppRoutes.cookiePolicy, wire: 'cookies'),
  openSourceLicenses(route: AppRoutes.openSourceLicenses, wire: 'licenses');

  const LegalDocument({required this.route, required this.wire});

  /// The route that opens the page (`AppNavigator.push(context, document.route)`).
  final String route;

  /// The `type` of its `legal_documents` row.
  final String wire;

  String l10n(BuildContext context) => switch (this) {
    LegalDocument.terms => context.l10n.terms,
    LegalDocument.privacy => context.l10n.privacyPolicy,
    LegalDocument.communityGuidelines => context.l10n.communityGuidelines,
    LegalDocument.cookiePolicy => context.l10n.cookiePolicy,
    LegalDocument.openSourceLicenses => context.l10n.openSourceLicenses,
  };
}
