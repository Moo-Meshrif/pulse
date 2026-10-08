import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/features/splash/presentation/widgets/splash_loading.dart';
import 'package:pulse/l10n/app_localizations.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/auth/domain/use_case/is_signed_in_use_case.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_step_use_case.dart';
import 'package:pulse/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:pulse/features/splash/presentation/screen/splash_screen.dart';

import '../../../../helpers/pump_app.dart' show l10nEn;

class MockIsSignedIn extends Mock implements IsSignedInUseCase {}

class MockGetSignupStep extends Mock implements GetSignupStepUseCase {}

/// The splash screen with the real cubit over mocked use cases, in an app whose every route just shows
/// its own name.
void main() {
  late MockIsSignedIn isSignedIn;
  late MockGetSignupStep getSignupStep;

  setUp(() async {
    isSignedIn = MockIsSignedIn();
    getSignupStep = MockGetSignupStep();
    await getIt.reset();
    getIt.registerFactory<SplashCubit>(
      () => SplashCubit(isSignedIn, getSignupStep),
    );
    addTearDown(getIt.reset);
  });

  Widget app() => MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const SplashScreen(),
    onGenerateRoute: (settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => Text('route: ${settings.name}'),
    ),
  );

  Future<void> openSplash(WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
  }

  testWidgets('no session goes to Sign in', (tester) async {
    when(() => isSignedIn()).thenReturn(false);

    await openSplash(tester);

    expect(find.text('route: /sign-in'), findsOneWidget);
    verifyNever(() => getSignupStep());
  });

  testWidgets('a finished sign-up goes Home', (tester) async {
    when(() => isSignedIn()).thenReturn(true);
    when(() => getSignupStep())
        .thenAnswer((_) async => const Right(SignupStep.complete));

    await openSplash(tester);

    expect(find.text('route: /home'), findsOneWidget);
  });

  testWidgets('a pending sign-up resumes at its saved step', (tester) async {
    when(() => isSignedIn()).thenReturn(true);
    when(() => getSignupStep())
        .thenAnswer((_) async => const Right(SignupStep.profile));

    await openSplash(tester);

    expect(find.text('route: /register?step=4'), findsOneWidget);
  });

  testWidgets('an expired session goes to Sign in', (tester) async {
    when(() => isSignedIn()).thenReturn(true);
    when(() => getSignupStep()).thenAnswer(
      (_) async => const Left(AuthFailure(AuthFailureReason.sessionExpired)),
    );

    await openSplash(tester);

    expect(find.text('route: /sign-in'), findsOneWidget);
  });

  testWidgets(
    'a lost connection stays on the offline screen, with no raw error',
    (tester) async {
      when(() => isSignedIn()).thenReturn(true);
      when(() => getSignupStep())
          .thenAnswer((_) async => const Left(NetworkFailure()));

      await openSplash(tester);

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text(l10nEn.offlineTitle), findsOneWidget);
      expect(find.text(l10nEn.offlineBody), findsOneWidget);
      expect(find.text(l10nEn.tryAgain), findsOneWidget);
      expect(find.textContaining('route:'), findsNothing);
      expect(find.textContaining('Exception'), findsNothing);
    },
  );

  testWidgets('any other failure shows Can\'t reach Pulse', (tester) async {
    when(() => isSignedIn()).thenReturn(true);
    when(() => getSignupStep())
        .thenAnswer((_) async => const Left(ServerFailure(statusCode: 500)));

    await openSplash(tester);

    expect(find.text(l10nEn.cantReachTitle), findsOneWidget);
    expect(find.text(l10nEn.cantReachBody), findsOneWidget);
    expect(find.textContaining('500'), findsNothing);
  });

  testWidgets('Try again shows loading, decides again and goes on', (
    tester,
  ) async {
    when(() => isSignedIn()).thenReturn(true);
    var calls = 0;
    when(() => getSignupStep()).thenAnswer((_) async {
      if (++calls == 1) return const Left(NetworkFailure());
      await Future<void>.delayed(const Duration(seconds: 1));
      return const Right(SignupStep.complete);
    });

    await openSplash(tester);
    await tester.tap(find.text(l10nEn.tryAgain));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(l10nEn.offlineTitle), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('route: /home'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('Try again that fails again returns to a problem screen', (
    tester,
  ) async {
    when(() => isSignedIn()).thenReturn(true);
    when(() => getSignupStep())
        .thenAnswer((_) async => const Left(NetworkFailure()));

    await openSplash(tester);
    await tester.tap(find.text(l10nEn.tryAgain));
    await tester.pumpAndSettle();

    expect(find.text(l10nEn.offlineTitle), findsOneWidget);
    verify(() => getSignupStep()).called(2);
  });

  testWidgets('the splash replaces itself: back does not return to it', (
    tester,
  ) async {
    when(() => isSignedIn()).thenReturn(false);

    await openSplash(tester);

    expect(find.byType(SplashScreen), findsNothing);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets(
    'while the profile loads the splash shows the S13 loading screen',
    (tester) async {
      when(() => isSignedIn()).thenReturn(true);
      when(() => getSignupStep()).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => const Right(SignupStep.complete),
        ),
      );

      await tester.pumpWidget(app());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(SplashLoading), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('route:'), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('route: /home'), findsOneWidget);
      expect(find.byType(SplashLoading), findsNothing); // gone with the splash
    },
  );

  testWidgets('the loading view is announced as Loading', (tester) async {
    final handle = tester.ensureSemantics();
    when(() => isSignedIn()).thenReturn(true);
    when(() => getSignupStep()).thenAnswer(
      (_) => Future.delayed(
        const Duration(seconds: 1),
        () => const Right(SignupStep.complete),
      ),
    );

    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.bySemanticsLabel('Loading'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    handle.dispose();
  });
}
