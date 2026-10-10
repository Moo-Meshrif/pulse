import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:pulse/features/auth/presentation/screen/sign_in_screen.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_step_use_case.dart';
import 'package:pulse/l10n/app_localizations.dart';

import '../../../../helpers/pump_app.dart';

class _MockGetSignupStep extends Mock implements GetSignupStepUseCase {}

/// Sign in with the real cubit over a mocked datasource and use case, in an app whose other routes show
/// their own name.
void main() {
  late MockAuthDatasource auth;
  late _MockGetSignupStep getSignupStep;

  setUp(() async {
    auth = MockAuthDatasource();
    getSignupStep = _MockGetSignupStep();
    when(() => getSignupStep()).thenAnswer((_) async => SignupStep.complete);
    await getIt.reset();
    getIt.registerFactory<SignInCubit>(() => SignInCubit(auth, getSignupStep));
    addTearDown(getIt.reset);
  });

  void signInReturns([Failure? failure]) =>
      when(
        () => auth.signIn(
          identifier: any(named: 'identifier'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {
        if (failure != null) throw failure;
      });

  Future<void> open(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SignInScreen(),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Text('route: ${settings.name}'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find
      .descendant(
        of: find.byType(AppTextField),
        matching: find.byType(TextField),
      )
      .at(label == 'identifier' ? 0 : 1);

  Future<void> fill(WidgetTester tester) async {
    await tester.enterText(field('identifier'), 'ada_l');
    await tester.enterText(field('password'), 'secret1');
    await tester.pump();
  }

  PrimaryButton button(WidgetTester tester) =>
      tester.widget<PrimaryButton>(find.byType(PrimaryButton));

  testView('shows the S1 content with Sign in enabled', (tester) async {
    await open(tester);

    expect(find.text(l10nEn.signInTitle), findsOneWidget);
    expect(find.text(l10nEn.signInSubtitle), findsOneWidget);
    expect(find.text(l10nEn.identifierLabel), findsOneWidget);
    expect(find.text(l10nEn.passwordLabel), findsOneWidget);
    expect(find.text(l10nEn.forgotPassword), findsOneWidget);
    expect(find.text(l10nEn.orContinueWith), findsOneWidget);
    expect(find.text(l10nEn.google), findsOneWidget);
    expect(
      find.textContaining(l10nEn.createAccount, findRichText: true),
      findsOneWidget,
    );
    expect(button(tester).onPressed, isNull);
  });

  testView('Sign in stays disabled until both fields have text', (
    tester,
  ) async {
    await open(tester);
    expect(button(tester).onPressed, isNull);

    await tester.enterText(field('identifier'), 'ada_l');
    await tester.pump();
    expect(button(tester).onPressed, isNull);

    await tester.enterText(field('password'), 'secret1');
    await tester.pump();
    expect(button(tester).onPressed, isNotNull);
  });

  testView('wrong credentials show the message in a snackbar', (tester) async {
    signInReturns(const AuthFailure(AuthFailureReason.invalidCredentials));
    await open(tester);
    await fill(tester);

    await tester.tap(find.text(l10nEn.signInButton));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(l10nEn.errorCredentials),
      ),
      findsOneWidget,
    );
    expect(button(tester).onPressed, isNotNull);
  });

  testView(
    'too many attempts show a snackbar and keep Sign in disabled until the countdown ends',
    (tester) async {
      signInReturns(
        const AuthFailure(
          AuthFailureReason.tooManyAttempts,
          retryAfter: Duration(seconds: 90),
        ),
      );
      await open(tester);
      await fill(tester);

      await tester.tap(find.text(l10nEn.signInButton));
      await tester.pump();
      await tester.pump();

      expect(find.text(l10nEn.errorTooManyAttempts('1:30')), findsOneWidget);
      expect(button(tester).onPressed, isNull);

      await tester.pump(const Duration(seconds: 90));
      expect(button(tester).onPressed, isNotNull);
    },
  );

  testView('a finished account goes Home', (tester) async {
    signInReturns();
    await open(tester);
    await fill(tester);

    await tester.tap(find.text(l10nEn.signInButton));
    await tester.pumpAndSettle();

    expect(find.text('route: /home'), findsOneWidget);
  });

  testView('an unfinished sign-up resumes at its step', (tester) async {
    signInReturns();
    when(() => getSignupStep()).thenAnswer((_) async => SignupStep.interests);
    await open(tester);
    await fill(tester);

    await tester.tap(find.text(l10nEn.signInButton));
    await tester.pumpAndSettle();

    expect(find.text('route: /register?step=5'), findsOneWidget);
  });

  testView('an unverified account opens Verify email with the server email', (
    tester,
  ) async {
    signInReturns(
      const AuthFailure(
        AuthFailureReason.emailNotConfirmed,
        email: 'ada@example.com',
      ),
    );
    when(() => auth.resendSignUpCode(any())).thenAnswer((_) async {});
    await open(tester);
    await fill(tester);

    await tester.tap(find.text(l10nEn.signInButton));
    await tester.pumpAndSettle();

    expect(
      find.text('route: /register?step=2&email=ada%40example.com'),
      findsOneWidget,
    );
    verify(() => auth.resendSignUpCode('ada@example.com')).called(1);
  });

  testView('Forgot password and Create account open their routes', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text(l10nEn.forgotPassword));
    await tester.pumpAndSettle();
    expect(find.text('route: /forgot-password'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(
      find.textContaining(l10nEn.createAccount, findRichText: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('route: /register'), findsOneWidget);
  });

  testView('Google shows the Coming soon snackbar', (tester) async {
    await open(tester);
    await tester.tap(find.text(l10nEn.google));
    await tester.pump();
    expect(find.text(l10nEn.comingSoon), findsOneWidget);
  });

  testView('the password is hidden until the eye is tapped', (tester) async {
    await open(tester);
    expect(tester.widget<TextField>(field('password')).obscureText, isTrue);
    await tester.tap(find.bySemanticsLabel(l10nEn.showPassword));
    await tester.pump();
    expect(tester.widget<TextField>(field('password')).obscureText, isFalse);
  });

  testView('Arabic: texts in Arabic, the identifier stays left-to-right', (
    tester,
  ) async {
    signInReturns(const AuthFailure(AuthFailureReason.invalidCredentials));
    await open(tester, locale: const Locale('ar'));

    expect(find.text(l10nAr.signInTitle), findsOneWidget);
    expect(find.text(l10nAr.identifierLabel), findsOneWidget);
    expect(
      find.textContaining(l10nAr.createAccount, findRichText: true),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(field('identifier')).textDirection,
      TextDirection.ltr,
    );
    expect(tester.widget<TextField>(field('password')).textDirection, isNull);

    // "Forgot password?" is at the start, i.e. the right edge, of the mirrored form... and
    // the form itself is mirrored: the label sits on the right.
    final titleRect = tester.getRect(find.text(l10nAr.signInTitle));
    expect(titleRect.right, greaterThan(390 / 2));

    await fill(tester);
    await tester.tap(find.text(l10nAr.signInButton));
    await tester.pumpAndSettle();
    expect(find.text(l10nAr.errorCredentials), findsOneWidget);
  });

  testView('a small phone with a 1.5 text scale scrolls without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    await open(tester);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    expect(
      find.textContaining(l10nEn.createAccount, findRichText: true),
      findsOneWidget,
    );
  });
}
