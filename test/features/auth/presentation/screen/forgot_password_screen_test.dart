import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/error/result.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/core/services/launch_service.dart';
import 'package:pulse/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:pulse/features/auth/presentation/screen/forgot_password_screen.dart';
import 'package:pulse/l10n/app_localizations.dart';

import '../../../../helpers/pump_app.dart';

class _MockLaunchService extends Mock implements LaunchService {}

/// Forgot password with the real cubits over a mocked datasource, pushed from a "home" so Back has
/// somewhere to go; other routes show their own name.
void main() {
  late MockAuthDatasource auth;
  late _MockLaunchService launcher;

  setUp(() async {
    auth = MockAuthDatasource();
    launcher = _MockLaunchService();
    when(() => launcher.openEmailApp()).thenAnswer((_) async => true);
    await getIt.reset();
    getIt.registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(auth, launcher),
    );
    addTearDown(getIt.reset);
  });

  void sendReturns(Result<Unit> result) =>
      when(() => auth.sendPasswordReset(any())).thenAnswer((_) async => result);

  Future<void> open(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: '/start',
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => switch (settings.name) {
            '/start' => const _Start(),
            '/forgot' => const ForgotPasswordScreen(),
            _ => Text('route: ${settings.name}'),
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  PrimaryButton sendButton(WidgetTester tester) =>
      tester.widget<PrimaryButton>(find.byType(PrimaryButton));

  Future<void> sendFor(WidgetTester tester, String email) async {
    await tester.enterText(find.byType(TextField), email);
    await tester.pump();
    await tester.ensureVisible(find.text(l10nEn.sendResetLink));
    await tester.pump();
    await tester.tap(find.text(l10nEn.sendResetLink));
    await tester.pumpAndSettle();
  }

  testView('shows the S2 content with Send disabled', (tester) async {
    await open(tester);

    expect(find.text(l10nEn.forgotTitle), findsOneWidget);
    expect(find.text(l10nEn.forgotSubtitle), findsOneWidget);
    expect(find.text(l10nEn.emailLabel), findsOneWidget);
    expect(find.text(l10nEn.backToSignIn), findsOneWidget);
    expect(sendButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'ada@example.com');
    await tester.pump();
    expect(sendButton(tester).onPressed, isNotNull);
  });

  testView(
    'a badly shaped email shows the format error once the field is left, Send stays off',
    (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextField), 'ada');
      await tester.pump();
      expect(find.text(l10nEn.errorInvalidEmail), findsNothing);
      expect(sendButton(tester).onPressed, isNull);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(find.text(l10nEn.errorInvalidEmail), findsOneWidget);
      expect(sendButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'ada@example.com');
      await tester.pump();
      expect(find.text(l10nEn.errorInvalidEmail), findsNothing);
      expect(sendButton(tester).onPressed, isNotNull);
      verifyNever(() => auth.sendPasswordReset(any()));
    },
  );

  testView('a failed request shows its failure in a snackbar', (tester) async {
    sendReturns(const Left(NetworkFailure()));
    await open(tester);
    await sendFor(tester, 'ada@example.com');

    expect(find.text(l10nEn.errorNetwork), findsOneWidget);
    expect(find.text(l10nEn.sentTitle), findsNothing);
  });

  testView(
    'a sent link opens the dialog over the screen with the masked email',
    (tester) async {
      sendReturns(const Right(unit));
      await open(tester);
      await sendFor(tester, 'ada@example.com');

      expect(find.text(l10nEn.sentTitle), findsOneWidget);
      expect(
        find.textContaining('ada•••@example.com', findRichText: true),
        findsOneWidget,
      );
      expect(find.text(l10nEn.forgotTitle), findsOneWidget); // still behind
      expect(find.text(l10nEn.resendLinkIn('0:30')), findsOneWidget);
    },
  );

  testView('Open email app launches the mail app, or says there is none', (
    tester,
  ) async {
    sendReturns(const Right(unit));
    await open(tester);
    await sendFor(tester, 'ada@example.com');

    await tester.tap(find.text(l10nEn.openEmailApp));
    await tester.pump();
    verify(() => launcher.openEmailApp()).called(1);
    expect(find.text(l10nEn.noEmailApp), findsNothing);

    when(() => launcher.openEmailApp()).thenAnswer((_) async => false);
    await tester.tap(find.text(l10nEn.openEmailApp));
    await tester.pump();
    expect(find.text(l10nEn.noEmailApp), findsOneWidget);
  });

  testView('Resend is available after 30 s and shows "Link sent again"', (
    tester,
  ) async {
    sendReturns(const Right(unit));
    await open(tester);
    await sendFor(tester, 'ada@example.com');

    await tester.tap(find.text(l10nEn.resendLinkIn('0:30')));
    await tester.pump();
    verify(() => auth.sendPasswordReset(any()))
        .called(1); // only the first send

    await tester.pump(const Duration(seconds: 30));
    await tester.tap(find.text(l10nEn.resendLink));
    await tester.pump();
    await tester.pump();

    // `verify` skips the calls it already checked, so this is the second send alone.
    verify(() => auth.sendPasswordReset('ada@example.com')).called(1);
    expect(find.text(l10nEn.linkResent), findsOneWidget);
    expect(find.text(l10nEn.resendLinkIn('0:30')), findsOneWidget);
  });

  testView('Change email closes the dialog and focuses the field', (
    tester,
  ) async {
    sendReturns(const Right(unit));
    await open(tester);
    await sendFor(tester, 'ada@example.com');

    await tester.tap(find.text(l10nEn.changeEmail));
    await tester.pumpAndSettle();

    expect(find.text(l10nEn.sentTitle), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
  });

  testView('a tap on the barrier closes the dialog and stays on S2', (
    tester,
  ) async {
    sendReturns(const Right(unit));
    await open(tester);
    await sendFor(tester, 'ada@example.com');

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(find.text(l10nEn.sentTitle), findsNothing);
    expect(find.text(l10nEn.forgotTitle), findsOneWidget);
  });

  testView('Back to sign in in the dialog resets to /sign-in', (tester) async {
    sendReturns(const Right(unit));
    await open(tester);
    await sendFor(tester, 'ada@example.com');

    await tester.tap(find.text(l10nEn.backToSignIn).last);
    await tester.pumpAndSettle();

    expect(find.text('route: /sign-in'), findsOneWidget);
  });

  testView('the back arrow and the pinned button go back', (tester) async {
    await open(tester);
    await tester.tap(find.bySemanticsLabel(l10nEn.back));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10nEn.backToSignIn));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });

  testView(
    'Arabic: texts in Arabic, the arrow on the right, email left-to-right',
    (tester) async {
      sendReturns(const Right(unit));
      await open(tester, locale: const Locale('ar'));

      expect(find.text(l10nAr.forgotTitle), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).textDirection,
        TextDirection.ltr,
      );
      final arrow = tester.getRect(find.bySemanticsLabel(l10nAr.back));
      expect(arrow.center.dx, greaterThan(390 / 2));

      await tester.enterText(find.byType(TextField), 'ada@example.com');
      await tester.pump();
      await tester.tap(find.text(l10nAr.sendResetLink));
      await tester.pumpAndSettle();
      expect(find.text(l10nAr.sentTitle), findsOneWidget);
      expect(find.text(l10nAr.resendLinkIn('0:30')), findsOneWidget);
    },
  );

  testView(
    'a small phone with 1.5 text scale shows the dialog without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      sendReturns(const Right(unit));
      await open(tester);
      await sendFor(tester, 'ada@example.com');

      expect(tester.takeException(), isNull);
      expect(find.text(l10nEn.sentTitle), findsOneWidget);
    },
  );
}

class _Start extends StatelessWidget {
  const _Start();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextButton(
      onPressed: () => Navigator.of(context).pushNamed('/forgot'),
      child: const Text('open'),
    ),
  );
}
