import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/enums/signed_out_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/auth/data/datasource/auth_datasource.dart';
import 'package:pulse/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:pulse/features/auth/presentation/cubit/sign_in_state.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/entity/last_account_entity.dart';
import 'package:pulse/features/profile/domain/use_case/forget_last_account_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_step_use_case.dart';

class MockAuth extends Mock implements AuthDatasource {}

class MockGetSignupStep extends Mock implements GetSignupStepUseCase {}

class MockGetLastAccount extends Mock implements GetLastAccountUseCase {}

class MockForgetLastAccount extends Mock implements ForgetLastAccountUseCase {}

void main() {
  late MockAuth auth;
  late MockGetSignupStep getSignupStep;
  late MockGetLastAccount getLastAccount;
  late MockForgetLastAccount forgetLastAccount;

  setUp(() {
    auth = MockAuth();
    getSignupStep = MockGetSignupStep();
    getLastAccount = MockGetLastAccount();
    forgetLastAccount = MockForgetLastAccount();
    when(() => getLastAccount()).thenReturn(null);
    when(() => forgetLastAccount()).thenAnswer((_) async {});
  });

  SignInCubit cubit() =>
      SignInCubit(auth, getSignupStep, getLastAccount, forgetLastAccount);

  void signInReturns([Failure? failure]) =>
      when(
        () => auth.signIn(
          identifier: any(named: 'identifier'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {
        if (failure != null) throw failure;
      });

  /// A cubit with both fields filled.
  SignInCubit filled([String identifier = 'ada@example.com']) => cubit()
    ..identifierChanged(identifier)
    ..passwordChanged('secret1');

  const filledState = SignInState(
    identifier: 'ada@example.com',
    password: 'secret1',
  );

  test('Sign in needs text in both fields', () {
    final c = cubit();
    expect(c.state.canSubmit, isFalse);
    c.identifierChanged('ada');
    expect(c.state.canSubmit, isFalse);
    c.passwordChanged('secret1');
    expect(c.state.canSubmit, isTrue);
    c.identifierChanged('   ');
    expect(c.state.canSubmit, isFalse);
  });

  blocTest<SignInCubit, SignInState>(
    'submit with an empty field sends nothing',
    build: cubit,
    act: (c) => c.submit(),
    expect: () => <SignInState>[],
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
      signInReturns();
      when(() => getSignupStep()).thenAnswer((_) async => SignupStep.complete);
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
      signInReturns();
      when(() => getSignupStep()).thenAnswer((_) async => SignupStep.complete);
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
        signInReturns();
        when(() => getSignupStep()).thenAnswer((_) async => step);
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
    setUp: () =>
        signInReturns(const AuthFailure(AuthFailureReason.invalidCredentials)),
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
    setUp: () => signInReturns(const NetworkFailure()),
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
      signInReturns();
      when(() => getSignupStep()).thenThrow(const NetworkFailure());
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
        const AuthFailure(
          AuthFailureReason.emailNotConfirmed,
          email: 'ada@example.com',
        ),
      );
      when(() => auth.resendSignUpCode(any())).thenAnswer((_) async {});
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
      signInReturns(throttle);
      final c = filled();
      unawaited(c.submit());
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
      signInReturns(throttle);
      final c = filled();
      unawaited(c.submit());
      await tester.pump();

      c.passwordChanged('another');
      expect(c.state.failure, throttle);
      expect(c.state.canSubmit, isFalse);
      await c.close();
    });

    testWidgets('closing the cubit stops the timer', (tester) async {
      signInReturns(throttle);
      final c = filled();
      unawaited(c.submit());
      await tester.pump();
      await c.close();
      // A leftover periodic timer would fail the test at teardown.
    });
  });

  group('after a session ended (S14)', () {
    const account = LastAccountEntity(
      id: 'u1',
      username: 'nour.adel',
      fullName: 'Nour Adel',
    );

    test('a plain Sign in ignores the account', () {
      final c = cubit()..start(null);
      expect(c.state.reason, isNull);
      expect(c.state.account, isNull);
      verifyNever(() => getLastAccount());
    });

    test('names the saved account and uses its username as the identifier', () {
      when(() => getLastAccount()).thenReturn(account);
      final c = cubit()..start(SignedOutReason.revoked);

      expect(c.state.reason, SignedOutReason.revoked);
      expect(c.state.account, account);
      expect(c.state.identifier, 'nour.adel');
      expect(c.state.canSubmit, isFalse, reason: 'the password is still empty');
      c.passwordChanged('secret1');
      expect(c.state.canSubmit, isTrue);
    });

    test('with no saved account the banner stays over the normal form', () {
      final c = cubit()..start(SignedOutReason.expired);
      expect(c.state.reason, SignedOutReason.expired);
      expect(c.state.account, isNull);
      expect(c.state.identifier, isEmpty);
    });

    test('signs in with the account\'s username', () async {
      when(() => getLastAccount()).thenReturn(account);
      signInReturns();
      when(() => getSignupStep()).thenAnswer((_) async => SignupStep.complete);
      final c = cubit()
        ..start(SignedOutReason.expired)
        ..passwordChanged('secret1');

      await c.submit();

      verify(() => auth.signIn(identifier: 'nour.adel', password: 'secret1'))
          .called(1);
    });

    test('"Not you?" forgets the account and shows the normal form', () async {
      when(() => getLastAccount()).thenReturn(account);
      final c = cubit()
        ..start(SignedOutReason.expired)
        ..passwordChanged('secret1');

      await c.forgetAccount();

      verify(() => forgetLastAccount()).called(1);
      expect(c.state.reason, isNull);
      expect(c.state.account, isNull);
      expect(c.state.identifier, isEmpty);
      expect(c.state.password, 'secret1');
    });

    test(
      '"Not you?" does nothing while signing in or without an account',
      () async {
        final c = cubit();
        await c.forgetAccount();
        verifyNever(() => forgetLastAccount());
      },
    );
  });
}
