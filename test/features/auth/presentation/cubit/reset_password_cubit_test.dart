import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/auth/presentation/cubit/reset_password_cubit.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late MockAuthDatasource auth;
  late StreamController<Unit> recovery;

  setUp(() {
    auth = MockAuthDatasource();
    recovery = StreamController<Unit>.broadcast();
    when(() => auth.currentEmail).thenReturn('ada@example.com');
    when(() => auth.passwordRecovery).thenAnswer((_) => recovery.stream);
    when(() => auth.updatePassword(any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => auth.signOut(others: any(named: 'others')))
        .thenAnswer((_) async => const Right(unit));
    addTearDown(recovery.close);
  });

  ResetPasswordCubit cubit() => ResetPasswordCubit(auth);

  ResetPasswordCubit filled() => cubit()
    ..passwordChanged('Password1')
    ..confirmChanged('Password1');

  test('starts with the recovery session\'s email and the checkbox on', () {
    final c = cubit();
    expect(c.state.email, 'ada@example.com');
    expect(c.state.linkExpired, isFalse);
    expect(c.state.logoutOthers, isTrue);
    expect(c.state.canSubmit, isFalse);
  });

  test('without a recovery session the link counts as expired', () {
    when(() => auth.currentEmail).thenReturn(null);
    expect(cubit().state.linkExpired, isTrue);
  });

  test(
    'a recovery event after opening turns the expired state into the form',
    () async {
      when(() => auth.currentEmail).thenReturn(null);
      final c = cubit();
      when(() => auth.currentEmail).thenReturn('ada@example.com');
      recovery.add(unit);
      await Future<void>.delayed(Duration.zero);

      expect(c.state.linkExpired, isFalse);
      expect(c.state.email, 'ada@example.com');
    },
  );

  test('Update needs all three rules and a matching confirmation', () {
    final c = cubit();
    for (final weak in ['short1A', 'password1', 'PASSWORD1', 'Passwordd']) {
      c.passwordChanged(weak);
      c.confirmChanged(weak);
      expect(c.state.canSubmit, isFalse, reason: weak);
    }
    c.passwordChanged('Password1');
    expect(c.state.canSubmit, isFalse);
    c.confirmChanged('Password1');
    expect(c.state.canSubmit, isTrue);
  });

  test('a confirmation that differs is a mismatch only once it has text', () {
    final c = cubit()..passwordChanged('Password1');
    expect(c.state.mismatch, isFalse);
    c.confirmChanged('Password');
    expect(c.state.mismatch, isTrue);
    c.confirmChanged('Password1');
    expect(c.state.mismatch, isFalse);
  });

  test('with the checkbox on, the other devices are signed out too', () async {
    final c = filled();
    await c.submit();

    expect(c.state.updated, isTrue);
    expect(c.state.othersLoggedOut, isTrue);
    expect(c.state.loading, isFalse);
    verifyInOrder([
      () => auth.updatePassword('Password1'),
      () => auth.signOut(others: true),
    ]);
  });

  test('with the checkbox off, no other device is signed out', () async {
    final c = filled()..logoutOthersChanged(false);
    await c.submit();

    expect(c.state.updated, isTrue);
    expect(c.state.othersLoggedOut, isFalse);
    verifyNever(() => auth.signOut(others: any(named: 'others')));
  });

  test('failing to sign out the others still finishes, saying so', () async {
    when(() => auth.signOut(others: true))
        .thenAnswer((_) async => const Left(NetworkFailure()));
    final c = filled();
    await c.submit();

    expect(c.state.updated, isTrue);
    expect(c.state.othersLoggedOut, isFalse);
  });

  test('a failed update keeps the form and reports the failure', () async {
    when(() => auth.updatePassword(any()))
        .thenAnswer((_) async => const Left(NetworkFailure()));
    final c = filled();
    await c.submit();

    expect(c.state.updated, isFalse);
    expect(c.state.loading, isFalse);
    expect(c.state.failure, const NetworkFailure());
    verifyNever(() => auth.signOut(others: any(named: 'others')));

    c.passwordChanged('Password12');
    expect(c.state.failure, isNull);
  });

  test(
    'submit does nothing while Update is disabled or after it succeeded',
    () async {
      final c = cubit();
      await c.submit();
      verifyNever(() => auth.updatePassword(any()));

      final done = filled();
      await done.submit();
      await done.submit();
      verify(() => auth.updatePassword(any())).called(1);
    },
  );

  test('leave signs out this session and goes to Sign in', () async {
    final c = cubit();
    final routes = <String>[];
    c.stream.listen((s) {
      if (s.route != null) routes.add(s.route!);
    });
    await c.leave();
    await Future<void>.delayed(Duration.zero);

    verify(() => auth.signOut()).called(1);
    expect(routes, [AppRoutes.signIn]);
    expect(c.state.route, isNull);
  });
}
