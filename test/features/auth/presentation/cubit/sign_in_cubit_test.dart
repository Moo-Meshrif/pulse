import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/error/result.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/auth/data/datasource/auth_datasource.dart';
import 'package:pulse/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:pulse/features/auth/presentation/cubit/sign_in_state.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_step_use_case.dart';

class MockAuth extends Mock implements AuthDatasource {}

class MockGetSignupStep extends Mock implements GetSignupStepUseCase {}

void main() {
  late MockAuth auth;
  late MockGetSignupStep getSignupStep;

  setUp(() {
    auth = MockAuth();
    getSignupStep = MockGetSignupStep();
  });

  SignInCubit cubit() => SignInCubit(auth, getSignupStep);

  void signInReturns(Result<Unit> result) => when(
    () => auth.signIn(
      identifier: any(named: 'identifier'),
      password: any(named: 'password'),
    ),
  ).thenAnswer((_) async => result);

  /// A cubit with both fields filled.
  SignInCubit filled([String identifier = 'ada@example.com']) => cubit()
    ..identifierChanged(identifier)
    ..passwordChanged('secret1');

  const filledState = SignInState(
    identifier: 'ada@example.com',
    password: 'secret1',
  );

  test('empty fields are only flagged once Sign in was pressed', () async {
    final c = cubit();
    expect(c.state.canSubmit, isTrue);
    expect(c.state.identifierMissing, isFalse);
    await c.submit();
    expect(c.state.identifierMissing, isTrue);
    expect(c.state.passwordMissing, isTrue);
    c.identifierChanged('ada');
    expect(c.state.identifierMissing, isFalse);
    expect(c.state.passwordMissing, isTrue);
    c.identifierChanged('   ');
    expect(c.state.identifierMissing, isTrue);
  });

  blocTest<SignInCubit, SignInState>(
    'submit with an empty field sends nothing',
    build: cubit,
    act: (c) => c.submit(),
    expect: () => [const SignInState(showRequired: true)],
    verify: (_) => verifyNever(
      () => auth.signIn(
        identifier: any(named: 'identifier'),
        password: any(named: 'password'),
      ),
    ),
  );

  blocTest<SignInCubit, SignInState>(
    'an email is sent as typed (trimmed) and a finished sign-up goes Home, clearing the stack',
    setUp: () {
      signInReturns(const Right(unit));
      when(() => getSignupStep())
          .thenAnswer((_) async => const Right(SignupStep.complete));
    },
    build: () => filled('  ada@example.com '),
    act: (c) => c.submit(),
    expect: () => [
      isA<SignInState>().having((s) => s.loading, 'loading', true),
      isA<SignInState>()
          .having((s) => s.route, 'route', AppRoutes.home)
          .having((s) => s.clearStack, 'clearStack', true),
      isA<SignInState>().having((s) => s.route, 'route', isNull),
    ],
    verify: (_) => verify(
      () => auth.signIn(identifier: 'ada@example.com', password: 'secret1'),
    ).called(1),
  );

  blocTest<SignInCubit, SignInState>(
    'a username takes the same path',
    setUp: () {
      signInReturns(const Right(unit));
      when(() => getSignupStep())
          .thenAnswer((_) async => const Right(SignupStep.complete));
    },
    build: () => filled('ada_l'),
    act: (c) => c.submit(),
    verify: (_) =>
        verify(() => auth.signIn(identifier: 'ada_l', password: 'secret1'))
            .called(1),
  );

  for (final step in [
    SignupStep.aboutYou,
    SignupStep.profile,
    SignupStep.interests,
    SignupStep.follow,
  ]) {
    blocTest<SignInCubit, SignInState>(
      'a pending sign-up resumes at step ${step.number}',
      setUp: () {
        signInReturns(const Right(unit));
        when(() => getSignupStep()).thenAnswer((_) async => Right(step));
      },
      build: filled,
      act: (c) => c.submit(),
      expect: () => [
        isA<SignInState>().having((s) => s.loading, 'loading', true),
        isA<SignInState>().having(
          (s) => s.route,
          'route',
          AppRoutes.registerAt(step.number),
        ),
        isA<SignInState>().having((s) => s.route, 'route', isNull),
      ],
    );
  }

  blocTest<SignInCubit, SignInState>(
    'wrong credentials (or an unknown username) show the failure and re-enable Sign in',
    setUp: () => signInReturns(
      const Left(AuthFailure(AuthFailureReason.invalidCredentials)),
    ),
    build: filled,
    act: (c) => c.submit(),
    expect: () => [
      filledState.copyWith(loading: true),
      filledState.copyWith(
        failure: const AuthFailure(AuthFailureReason.invalidCredentials),
      ),
    ],
    verify: (c) => expect(c.state.canSubmit, isTrue),
  );

  blocTest<SignInCubit, SignInState>(
    'editing a field clears the credentials error',
    seed: () => filledState.copyWith(
      failure: const AuthFailure(AuthFailureReason.invalidCredentials),
    ),
    build: cubit,
    act: (c) => c.passwordChanged('secret2'),
    expect: () => [
      const SignInState(identifier: 'ada@example.com', password: 'secret2'),
    ],
  );

  blocTest<SignInCubit, SignInState>(
    'a lost connection is a failure the view words, not a route',
    setUp: () => signInReturns(const Left(NetworkFailure())),
    build: filled,
    act: (c) => c.submit(),
    expect: () => [
      filledState.copyWith(loading: true),
      filledState.copyWith(failure: const NetworkFailure()),
    ],
  );

  blocTest<SignInCubit, SignInState>(
    'signed in but the profile cannot be read: a failure, no route',
    setUp: () {
      signInReturns(const Right(unit));
      when(() => getSignupStep())
          .thenAnswer((_) async => const Left(NetworkFailure()));
    },
    build: filled,
    act: (c) => c.submit(),
    expect: () => [
      filledState.copyWith(loading: true),
      filledState.copyWith(failure: const NetworkFailure()),
    ],
  );

  blocTest<SignInCubit, SignInState>(
    'an unverified account gets a new code and opens Verify email with the returned email',
    setUp: () {
      signInReturns(
        const Left(
          AuthFailure(
            AuthFailureReason.emailNotConfirmed,
            email: 'ada@example.com',
          ),
        ),
      );
      when(() => auth.resendSignUpCode(any()))
          .thenAnswer((_) async => const Right(unit));
    },
    build: () => filled('ada_l'),
    act: (c) => c.submit(),
    expect: () => [
      isA<SignInState>().having((s) => s.loading, 'loading', true),
      isA<SignInState>()
          .having(
            (s) => s.route,
            'route',
            AppRoutes.verifyEmailAt('ada@example.com'),
          )
          .having((s) => s.clearStack, 'clearStack', false),
      isA<SignInState>().having((s) => s.route, 'route', isNull),
    ],
    verify: (_) =>
        verify(() => auth.resendSignUpCode('ada@example.com')).called(1),
  );

  group('too many attempts', () {
    const throttle = AuthFailure(
      AuthFailureReason.tooManyAttempts,
      retryAfter: Duration(seconds: 3),
    );

    testWidgets('disables Sign in and counts down, then enables it again', (
      tester,
    ) async {
      signInReturns(const Left(throttle));
      final c = filled();
      c.submit();
      await tester.pump();

      expect(c.state.failure, throttle);
      expect(c.state.retryIn, const Duration(seconds: 3));
      expect(c.state.canSubmit, isFalse);

      await tester.pump(const Duration(seconds: 2));
      expect(c.state.retryIn, const Duration(seconds: 1));
      expect(c.state.canSubmit, isFalse);

      await tester.pump(const Duration(seconds: 1));
      expect(c.state.retryIn, isNull);
      expect(c.state.failure, isNull);
      expect(c.state.canSubmit, isTrue);
      await c.close();
    });

    testWidgets('typing during the countdown keeps the message and the lock', (
      tester,
    ) async {
      signInReturns(const Left(throttle));
      final c = filled();
      c.submit();
      await tester.pump();

      c.passwordChanged('another');
      expect(c.state.failure, throttle);
      expect(c.state.canSubmit, isFalse);
      await c.close();
    });

    testWidgets('closing the cubit stops the timer', (tester) async {
      signInReturns(const Left(throttle));
      final c = filled();
      c.submit();
      await tester.pump();
      await c.close();
      // A leftover periodic timer would fail the test at teardown.
    });
  });
}
