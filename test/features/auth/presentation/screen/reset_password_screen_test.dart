import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:pulse/features/auth/presentation/screen/reset_password_screen.dart';
import 'package:pulse/features/auth/presentation/widgets/auth_close_button.dart';
import 'package:pulse/features/auth/presentation/widgets/labeled_checkbox.dart';
import 'package:pulse/l10n/app_localizations.dart';

import '../../../../helpers/pump_app.dart';

/// Set a new password and its dialog with the real cubit over a mocked datasource, in an app whose other
/// routes show their own name.
void main() {
  late MockAuthDatasource auth;

  setUp(() async {
    auth = MockAuthDatasource();
    when(() => auth.currentEmail).thenReturn('ada.lovelace@example.com');
    when(() => auth.passwordRecovery).thenAnswer((_) => const Stream.empty());
    when(() => auth.updatePassword(any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => auth.signOut(others: any(named: 'others')))
        .thenAnswer((_) async => const Right(unit));
    await getIt.reset();
    getIt.registerFactory<ResetPasswordCubit>(() => ResetPasswordCubit(auth));
    addTearDown(getIt.reset);
  });

  Future<void> open(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(
      AppScaleScope(
        builder: (context) => MaterialApp(
          theme: AppTheme.light,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ResetPasswordScreen(),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => Text('route: ${settings.name}'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(int index) => find
      .descendant(
        of: find.byType(AppTextField),
        matching: find.byType(TextField),
      )
      .at(index);

  PrimaryButton button(WidgetTester tester) =>
      tester.widget<PrimaryButton>(find.byType(PrimaryButton));

  Future<void> fill(WidgetTester tester, {String confirm = 'Password1'}) async {
    await tester.enterText(field(0), 'Password1');
    await tester.enterText(field(1), confirm);
    await tester.pump();
  }

  testView('shows the S11 content with Update disabled and the checkbox on', (
    tester,
  ) async {
    await open(tester);

    expect(find.byType(AuthCloseButton), findsOneWidget);
    expect(find.text(l10nEn.resetTitle), findsOneWidget);
    expect(
      find.textContaining('ada•••@example.com', findRichText: true),
      findsOneWidget,
    );
    expect(find.text(l10nEn.ruleLength), findsWidgets);
    expect(find.text(l10nEn.ruleNumber), findsOneWidget);
    expect(find.text(l10nEn.ruleCase), findsOneWidget);
    expect(find.text(l10nEn.logoutOthers), findsOneWidget);
    expect(
      tester.widget<LabeledCheckbox>(find.byType(LabeledCheckbox)).checked,
      isTrue,
    );
    expect(button(tester).onPressed, isNull);
  });

  testView('the rules turn met as the password grows', (tester) async {
    await open(tester);
    expect(
      find.bySemanticsLabel(l10nEn.ruleNotMet(l10nEn.ruleLength)),
      findsOneWidget,
    );

    await tester.enterText(field(0), 'Password1');
    await tester.pump();
    expect(
      find.bySemanticsLabel(l10nEn.ruleMet(l10nEn.ruleLength)),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(l10nEn.ruleMet(l10nEn.ruleNumber)),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(l10nEn.ruleMet(l10nEn.ruleCase)),
      findsOneWidget,
    );
  });

  testView('a different confirmation shows the mismatch and keeps Update off', (
    tester,
  ) async {
    await open(tester);
    await fill(tester, confirm: 'Password');

    expect(find.text(l10nEn.errorMismatch), findsOneWidget);
    expect(button(tester).onPressed, isNull);

    await tester.enterText(field(1), 'Password1');
    await tester.pump();
    expect(find.text(l10nEn.errorMismatch), findsNothing);
    expect(button(tester).onPressed, isNotNull);
  });

  testView('Update with the checkbox on logs out the others and shows S12', (
    tester,
  ) async {
    await open(tester);
    await fill(tester);
    await tester.tap(find.text(l10nEn.updatePassword));
    await tester.pumpAndSettle();

    verify(() => auth.signOut(others: true)).called(1);
    expect(find.text(l10nEn.updatedTitle), findsOneWidget);
    expect(find.text(l10nEn.updatedBodyOthers), findsOneWidget);
  });

  testView('Update with the checkbox off shows the shorter body', (
    tester,
  ) async {
    await open(tester);
    await fill(tester);
    await tester.ensureVisible(find.byType(LabeledCheckbox));
    await tester.pump();
    await tester.tap(find.byType(LabeledCheckbox));
    await tester.pump();
    await tester.tap(find.text(l10nEn.updatePassword));
    await tester.pumpAndSettle();

    verifyNever(() => auth.signOut(others: any(named: 'others')));
    expect(find.text(l10nEn.updatedBody), findsOneWidget);
  });

  testView(
    'S12 ignores the barrier and system back; Sign in signs out and leaves',
    (tester) async {
      await open(tester);
      await fill(tester);
      await tester.tap(find.text(l10nEn.updatePassword));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.updatedTitle), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.updatedTitle), findsOneWidget);

      await tester.tap(find.text(l10nEn.signIn));
      await tester.pumpAndSettle();
      verify(() => auth.signOut()).called(1);
      expect(find.text('route: ${AppRoutes.signIn}'), findsOneWidget);
    },
  );

  testView('a failed update shows the message and keeps the form', (
    tester,
  ) async {
    when(() => auth.updatePassword(any()))
        .thenAnswer((_) async => const Left(NetworkFailure()));
    await open(tester);
    await fill(tester);
    await tester.tap(find.text(l10nEn.updatePassword));
    await tester.pumpAndSettle();

    expect(find.text(l10nEn.errorNetwork), findsOneWidget);
    expect(find.text(l10nEn.updatedTitle), findsNothing);
    expect(button(tester).onPressed, isNotNull);
  });

  testView('the X signs out the recovery session and opens Sign in', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    await tester.pumpAndSettle();

    verify(() => auth.signOut()).called(1);
    expect(find.text('route: ${AppRoutes.signIn}'), findsOneWidget);
  });

  group('expired link', () {
    setUp(() => when(() => auth.currentEmail).thenReturn(null));

    testView('shows the message and no form', (tester) async {
      await open(tester);

      expect(find.text(l10nEn.linkExpiredTitle), findsOneWidget);
      expect(find.text(l10nEn.linkExpiredBody), findsOneWidget);
      expect(find.byType(AppTextField), findsNothing);
    });

    testView('"Request a new link" opens Forgot password', (tester) async {
      await open(tester);
      await tester.tap(find.text(l10nEn.requestNewLink));
      await tester.pumpAndSettle();

      expect(find.text('route: ${AppRoutes.forgotPassword}'), findsOneWidget);
    });

    testView('the X still goes to Sign in', (tester) async {
      await open(tester);
      await tester.tap(find.bySemanticsLabel(l10nEn.close));
      await tester.pumpAndSettle();

      expect(find.text('route: ${AppRoutes.signIn}'), findsOneWidget);
    });
  });

  testView('Arabic: texts are Arabic and the X sits on the right', (
    tester,
  ) async {
    await open(tester, locale: const Locale('ar'));

    expect(find.text(l10nAr.resetTitle), findsOneWidget);
    expect(find.text(l10nAr.updatePassword), findsOneWidget);
    final x = tester.getCenter(find.byType(AuthCloseButton));
    expect(x.dx, greaterThan(195));
  });

  testWidgets('at 320 dp and 1.5x text nothing overflows', (tester) async {
    setUpView(tester, size: const Size(320, 640), textScale: 1.5);
    await open(tester);
    expect(tester.takeException(), isNull);
  });
}
