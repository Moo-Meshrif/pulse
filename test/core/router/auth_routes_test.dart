import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/legal_document.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/control/presentation/screen/control_screen.dart';
import 'package:pulse/features/legal/data/model/legal_document_model.dart';

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

  group('legal pages', () {
    const terms = LegalDocumentModel(
      title: 'Terms of Use',
      html: '<h1>Heading</h1><p>Body text</p>',
      locale: 'en',
    );

    Future<MockLegalDatasource> openLegal(
      WidgetTester tester,
      String route,
    ) async {
      final legal = MockLegalDatasource();
      when(() => legal.getDocument(any(), any()))
          .thenAnswer((_) async => terms);
      setUpView(tester);
      await tester.bootApp(prefs: {'onboarding_seen': true}, legal: legal);
      tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
      await tester.pumpAndSettle();
      return legal;
    }

    testWidgets('/terms shows the HTML', (tester) async {
      final legal = await openLegal(tester, AppRoutes.terms);
      verify(() => legal.getDocument('terms', 'en')).called(1);
      expect(
        find.textContaining('Body text', findRichText: true),
        findsOneWidget,
      );
    });

    for (final document in LegalDocument.values) {
      testWidgets(
        '${document.route} asks for the "${document.wire}" document',
        (tester) async {
          final legal = await openLegal(tester, document.route);
          verify(() => legal.getDocument(document.wire, 'en')).called(1);
        },
      );
    }

    testWidgets('/privacy asks for the privacy document', (tester) async {
      final legal = await openLegal(tester, AppRoutes.privacy);
      verify(() => legal.getDocument('privacy', 'en')).called(1);
    });

    testWidgets('a failed load shows Retry, which loads again', (tester) async {
      final legal = MockLegalDatasource();
      var calls = 0;
      when(() => legal.getDocument(any(), any())).thenAnswer((_) async {
        if (calls++ == 0) throw const NetworkFailure();
        return terms;
      });
      setUpView(tester);
      await tester.bootApp(prefs: {'onboarding_seen': true}, legal: legal);
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed(AppRoutes.terms);
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.retry), findsOneWidget);

      await tester.tap(find.text(l10nEn.retry));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Body text', findRichText: true),
        findsOneWidget,
      );
      expect(find.text(l10nEn.retry), findsNothing);
    });
  });

  testWidgets('/register opens the sign-up Account step', (tester) async {
    await openRoute(tester, AppRoutes.register);
    expect(find.text(l10nEn.signUpTitle), findsOneWidget);
  });

  testWidgets('/register?step=2&email=… opens Verify email for that address', (
    tester,
  ) async {
    setUpView(tester);
    await tester.bootApp(prefs: {'onboarding_seen': true});
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed(AppRoutes.verifyEmailAt('ada@example.com'));
    // The code boxes blink a cursor for ever, so the page never settles.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(l10nEn.verifyTitle), findsOneWidget);
    expect(
      find.textContaining('ada•••@example.com', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets(
    '/reset-password without a recovery session says the link expired',
    (tester) async {
      await openRoute(tester, AppRoutes.resetPassword);
      expect(find.text(l10nEn.linkExpiredTitle), findsOneWidget);
      expect(find.text(l10nEn.requestNewLink), findsOneWidget);
    },
  );

  testWidgets('${AppRoutes.home} opens the main shell', (tester) async {
    await openRoute(tester, AppRoutes.home);
    expect(find.byType(ControlScreen), findsOneWidget);
  });
}
