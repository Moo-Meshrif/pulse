import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/auth/presentation/utils/enums/legal_document.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> openRoute(WidgetTester tester, String route) async {
    setUpView(tester);
    await tester.bootApp(prefs: {'onboarding_seen': true});
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
    await tester.pumpAndSettle();
  }

  test('each legal document knows its route', () {
    expect(LegalDocument.terms.route, AppRoutes.terms);
    expect(LegalDocument.privacy.route, AppRoutes.privacy);
  });

  testWidgets('/terms shows the title and "Coming soon"', (tester) async {
    await openRoute(tester, AppRoutes.terms);
    expect(find.text(l10nEn.terms), findsOneWidget);
    expect(find.text(l10nEn.comingSoon), findsOneWidget);
  });

  testWidgets('/privacy shows the title and "Coming soon"', (tester) async {
    await openRoute(tester, AppRoutes.privacy);
    expect(find.text(l10nEn.privacyPolicy), findsOneWidget);
    expect(find.text(l10nEn.comingSoon), findsOneWidget);
  });

  for (final route in [AppRoutes.home, AppRoutes.resetPassword]) {
    testWidgets('$route opens its placeholder', (tester) async {
      await openRoute(tester, route);
      expect(find.text(route), findsOneWidget);
    });
  }
}
