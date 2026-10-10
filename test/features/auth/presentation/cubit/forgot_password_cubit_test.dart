import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/launch_service.dart';
import 'package:pulse/features/auth/data/datasource/auth_datasource.dart';
import 'package:pulse/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:pulse/features/auth/presentation/cubit/forgot_password_state.dart';
import 'package:pulse/features/auth/presentation/utils/enums/reset_link_message.dart';

class MockAuth extends Mock implements AuthDatasource {}

class MockLaunchService extends Mock implements LaunchService {}

void main() {
  late MockAuth auth;
  late MockLaunchService launcher;

  setUp(() {
    auth = MockAuth();
    launcher = MockLaunchService();
  });

  ForgotPasswordCubit cubit() => ForgotPasswordCubit(auth, launcher);

  void sendReturns([Failure? failure]) =>
      when(() => auth.sendPasswordReset(any())).thenAnswer((_) async {
        if (failure != null) throw failure;
      });

  const cooldown = Duration(seconds: 30);

  test('Send is disabled until the email is valid', () {
    final c = cubit();
    expect(c.state.canSubmit, isFalse);
    c.emailChanged('  ');
    expect(c.state.canSubmit, isFalse);
    c.emailChanged('ada@');
    expect(c.state.canSubmit, isFalse);
    c.emailChanged('ada@example.com');
    expect(c.state.canSubmit, isTrue);
  });

  test(
    'the format error shows only after leaving a non-empty invalid email',
    () {
      final c = cubit();
      c.emailChanged('ada');
      expect(c.state.emailInvalidShown, isFalse);
      c.emailLeft();
      expect(c.state.emailInvalidShown, isTrue);
      c.emailChanged('ada@example.com');
      expect(c.state.emailInvalidShown, isFalse);
    },
  );

  testWidgets(
    'a sent link hands the trimmed email to the screen once and starts the cooldown',
    (tester) async {
      sendReturns();
      final c = cubit()..emailChanged(' ada@example.com ');
      final sentTo = <String?>[];
      c.stream.listen((s) => sentTo.add(s.sentTo));

      await c.submit();
      await tester.pump();

      expect(sentTo.whereType<String>(), ['ada@example.com']);
      expect(c.state.sentTo, isNull);
      expect(c.state.loading, isFalse);
      expect(c.state.cooldown, cooldown);
      expect(c.state.canResend, isFalse);
      verify(() => auth.sendPasswordReset('ada@example.com')).called(1);
      await c.close();
    },
  );

  blocTest<ForgotPasswordCubit, ForgotPasswordState>(
    'a failed request keeps the email, reports the failure and starts no cooldown',
    setUp: () => sendReturns(const AuthFailure(AuthFailureReason.rateLimited)),
    build: cubit,
    seed: () => const ForgotPasswordState(email: 'ada@example.com'),
    act: (c) => c.submit(),
    expect: () => [
      const ForgotPasswordState(email: 'ada@example.com', loading: true),
      const ForgotPasswordState(
        email: 'ada@example.com',
        failure: AuthFailure(AuthFailureReason.rateLimited),
      ),
    ],
  );

  blocTest<ForgotPasswordCubit, ForgotPasswordState>(
    'Change email asks the view to focus the field',
    build: cubit,
    act: (c) => c.editEmail(),
    expect: () => [const ForgotPasswordState(focusRequest: 1)],
  );

  group('the dialog', () {
    /// A cubit whose link was just sent.
    Future<ForgotPasswordCubit> sent(WidgetTester tester) async {
      sendReturns();
      final c = cubit()..emailChanged('ada@example.com');
      await c.submit();
      await tester.pump();
      return c;
    }

    testWidgets('Resend counts down 30 s, then works', (tester) async {
      final c = await sent(tester);

      await tester.pump(const Duration(seconds: 29));
      expect(c.state.cooldown, const Duration(seconds: 1));
      expect(c.state.canResend, isFalse);

      await tester.pump(const Duration(seconds: 1));
      expect(c.state.cooldown, Duration.zero);
      expect(c.state.canResend, isTrue);
      await c.close();
    });

    testWidgets('Resend during the cooldown does nothing', (tester) async {
      final c = await sent(tester);
      await c.resend();
      verify(() => auth.sendPasswordReset(any()))
          .called(1); // the first send only
      await c.close();
    });

    testWidgets('Resend sends again, says so once and restarts the cooldown', (
      tester,
    ) async {
      final c = await sent(tester);
      await tester.pump(cooldown);
      final messages = <ResetLinkMessage?>[];
      c.stream.listen((s) => messages.add(s.message));

      await c.resend();
      await tester.pump();

      verify(() => auth.sendPasswordReset('ada@example.com')).called(2);
      expect(messages.whereType<ResetLinkMessage>(), [ResetLinkMessage.resent]);
      expect(c.state.message, isNull);
      expect(c.state.cooldown, cooldown);
      expect(c.state.loading, isFalse);
      await c.close();
    });

    testWidgets('a failed Resend says so and can be tried again', (
      tester,
    ) async {
      final c = await sent(tester);
      await tester.pump(cooldown);
      sendReturns(const NetworkFailure());
      final messages = <ResetLinkMessage?>[];
      c.stream.listen((s) => messages.add(s.message));

      await c.resend();
      await tester.pump();

      expect(messages.whereType<ResetLinkMessage>(), [
        ResetLinkMessage.resendFailed,
      ]);
      expect(c.state.canResend, isTrue);
      expect(c.state.failure, isNull); // the screen's snackbar is for Send only
      await c.close();
    });

    testWidgets('Open email app says so when there is no mail app', (
      tester,
    ) async {
      when(() => launcher.openEmailApp()).thenAnswer((_) async => false);
      final c = cubit();
      final messages = <ResetLinkMessage?>[];
      c.stream.listen((s) => messages.add(s.message));

      await c.openEmailApp();
      await tester.pump();

      expect(messages.whereType<ResetLinkMessage>(), [
        ResetLinkMessage.noEmailApp,
      ]);
      await c.close();
    });

    testWidgets('Open email app is quiet when it opens', (tester) async {
      when(() => launcher.openEmailApp()).thenAnswer((_) async => true);
      final c = cubit();
      final messages = <ResetLinkMessage?>[];
      c.stream.listen((s) => messages.add(s.message));

      await c.openEmailApp();
      await tester.pump();

      expect(messages.whereType<ResetLinkMessage>(), isEmpty);
      await c.close();
    });

    testWidgets('closing the cubit stops the cooldown timer', (tester) async {
      final c = await sent(tester);
      await c.close();
      // A leftover periodic timer would fail the test at teardown.
    });
  });
}
