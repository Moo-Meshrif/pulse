// ignore_for_file: invalid_use_of_internal_member
// The tests feed gotrue's own event stream, the way a deep link does inside supabase_flutter.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/constants/app_config.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/enums/recovery_signal.dart';
import 'package:pulse/core/enums/signed_out_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/storage/local_storage.dart';
import 'package:pulse/core/services/storage/storage_keys.dart';
import 'package:pulse/features/auth/data/datasource/auth_datasource.dart';
import 'package:pulse/features/auth/data/datasource/password_recovery_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../helpers/backend_double.dart';
import '../../../../helpers/memory_snapshot_storage.dart';

void main() {
  late SharedPrefsStorageService storage;
  late PasswordRecoveryTracker tracker;
  late MemorySnapshotStorage snapshots;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = SharedPrefsStorageService(await SharedPreferences.getInstance());
    tracker = PasswordRecoveryTracker(storage);
    snapshots = MemorySnapshotStorage();
  });

  tearDown(() => tracker.dispose());

  Future<Failure?> failureOf(Future<Object?> call) async {
    try {
      await call;
    } on Failure catch (failure) {
      return failure;
    }
    return null;
  }

  Map<String, dynamic> body(http.Request request) =>
      jsonDecode(request.body) as Map<String, dynamic>;

  group('signIn', () {
    BackendDouble signInBackend({http.Response? function, Object? throwing}) =>
        BackendDouble((request) async {
          if (request.url.path.endsWith('/functions/v1/sign-in')) {
            if (throwing != null) throw throwing;
            return function ??
                BackendDouble.json({
                  'access_token': 'a',
                  'refresh_token': 'refresh',
                  'expires_in': 3600,
                  'expires_at': 4102444800,
                  'token_type': 'bearer',
                });
          }
          return BackendDouble.sessionResponse();
        });

    test('calls the sign-in function, then stores the session from its refresh token', () async {
      final backend = signInBackend();
      final datasource = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      );

      await datasource.signIn(identifier: ' dip.roy ', password: 'secret');

      expect(body(backend.to('/functions/v1/sign-in').single), {
        'identifier': 'dip.roy',
        'password': 'secret',
      });
      final grant = backend.to('/token').single;
      expect(grant.url.queryParameters['grant_type'], 'refresh_token');
      expect(body(grant)['refresh_token'], 'refresh');
      expect(datasource.hasSession, isTrue);
    });

    test(
      'never resolves the username to an email or grants a password',
      () async {
        final backend = signInBackend();
        await SupabaseAuthDatasource(
          backend.client,
          tracker,
          snapshots,
        ).signIn(identifier: 'dip.roy', password: 'secret');

        expect(backend.to('get_email_for_username'), isEmpty);
        expect(
          backend.to('/token').map((r) => r.url.queryParameters['grant_type']),
          isNot(contains('password')),
        );
        expect(
          backend.requests.where((r) => r.url.path.contains('/rpc/')),
          isEmpty,
        );
      },
    );

    test(
      'a wrong password or unknown user is invalidCredentials, no session',
      () async {
        final backend = signInBackend(
          function: BackendDouble.json({
            'code': 'invalid_credentials',
          }, status: 401),
        );
        final datasource = SupabaseAuthDatasource(
          backend.client,
          tracker,
          snapshots,
        );

        final result = datasource.signIn(identifier: 'nobody', password: 'x');

        expect(
          await failureOf(result),
          const AuthFailure(AuthFailureReason.invalidCredentials),
        );
        expect(backend.to('/token'), isEmpty);
        expect(datasource.hasSession, isFalse);
      },
    );

    test(
      'an unverified account is emailNotConfirmed and carries the email',
      () async {
        final backend = signInBackend(
          function: BackendDouble.json({
            'code': 'email_not_confirmed',
            'email': 'dip@example.com',
          }, status: 403),
        );
        final result = SupabaseAuthDatasource(
          backend.client,
          tracker,
          snapshots,
        ).signIn(identifier: 'dip.roy', password: 'x');

        final failure = (await failureOf(result))! as AuthFailure;
        expect(failure.reason, AuthFailureReason.emailNotConfirmed);
        expect(failure.email, 'dip@example.com');
        expect(failure.retryAfter, isNull);
      },
    );

    test('too many attempts carries the wait', () async {
      final backend = signInBackend(
        function: BackendDouble.json({
          'code': 'rate_limited',
          'retry_after': 897,
        }, status: 429),
      );
      final result = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).signIn(identifier: 'dip.roy', password: 'x');

      final failure = (await failureOf(result))! as AuthFailure;
      expect(failure.reason, AuthFailureReason.tooManyAttempts);
      expect(failure.retryAfter, const Duration(seconds: 897));
      expect(failure.email, isNull);
    });

    test('a server error is a ServerFailure', () async {
      final backend = signInBackend(
        function: BackendDouble.json({'code': 'server_error'}, status: 500),
      );
      final result = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).signIn(identifier: 'a@b.co', password: 'x');
      expect(await failureOf(result), const ServerFailure(statusCode: 500));
    });

    test('an answer without a refresh token is a ParseFailure', () async {
      final backend = signInBackend(function: BackendDouble.json({'ok': true}));
      final result = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).signIn(identifier: 'a@b.co', password: 'x');
      expect(await failureOf(result), const ParseFailure());
    });

    test('offline is a NetworkFailure', () async {
      final backend = signInBackend(throwing: http.ClientException('offline'));
      final result = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).signIn(identifier: 'a@b.co', password: 'x');
      expect(await failureOf(result), const NetworkFailure());
    });
  });

  group('signUp', () {
    test('a new address succeeds', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.json(
          BackendDouble.userJson(
            identities: [
              {
                'id': 'i',
                'user_id': BackendDouble.uid,
                'identity_id': 'i',
                'provider': 'email',
                'created_at': '2026-01-01T00:00:00Z',
                'identity_data': <String, dynamic>{},
              },
            ],
          ),
        ),
      );
      final alreadyRegistered = await SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).signUp(email: 'new@example.com', password: 'Passw0rd!');
      expect(alreadyRegistered, isFalse);
      expect(body(backend.to('/signup').single)['email'], 'new@example.com');
    });

    test('an existing address (a user with no identities) is reported, not refused', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.json(BackendDouble.userJson(identities: [])),
      );
      final alreadyRegistered = await SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).signUp(email: 'taken@example.com', password: 'Passw0rd!');
      expect(alreadyRegistered, isTrue);
    });

    test('a weak password is weakPassword', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.authError(422, 'weak_password'),
      );
      final result = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).signUp(email: 'a@b.co', password: '1');
      expect(
        await failureOf(result),
        const AuthFailure(AuthFailureReason.weakPassword),
      );
    });
  });

  group('verify and resend', () {
    test('a correct code posts a signup verification', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.sessionResponse(),
      );
      await SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).verifySignUpCode(email: 'dip@example.com', code: '123456');
      expect(
        body(backend.to('/verify').single),
        containsPair('type', 'signup'),
      );
      expect(
        body(backend.to('/verify').single),
        containsPair('token', '123456'),
      );
    });

    test('a wrong code is invalidCode', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.authError(403, 'otp_expired'),
      );
      final result = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).verifySignUpCode(email: 'dip@example.com', code: '000000');
      expect(
        await failureOf(result),
        const AuthFailure(AuthFailureReason.invalidCode),
      );
    });

    test('resend asks for a new signup code', () async {
      final backend = BackendDouble((_) async => BackendDouble.json({}));
      await SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).resendSignUpCode('dip@example.com');
      expect(
        body(backend.to('/resend').single),
        containsPair('type', 'signup'),
      );
    });

    test('too many emails is rateLimited', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.authError(429, 'over_email_send_rate_limit'),
      );
      final result = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).resendSignUpCode('a@b.co');
      expect(
        await failureOf(result),
        const AuthFailure(AuthFailureReason.rateLimited),
      );
    });
  });

  group('password reset', () {
    test('the reset email links back to the app', () async {
      final backend = BackendDouble((_) async => BackendDouble.json({}));
      await SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).sendPasswordReset(' dip@example.com ');
      final request = backend.to('/recover').single;
      expect(
        request.url.queryParameters['redirect_to'],
        AppConfig.recoveryRedirectUrl,
      );
      expect(body(request)['email'], 'dip@example.com');
    });

    test('too many reset emails is rateLimited', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.authError(429, 'over_email_send_rate_limit'),
      );
      final result = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).sendPasswordReset('a@b.co');
      expect(
        await failureOf(result),
        const AuthFailure(AuthFailureReason.rateLimited),
      );
    });

    test('updatePassword puts the new password on the user', () async {
      final backend = BackendDouble((request) async {
        if (request.url.path.endsWith('/user')) {
          return BackendDouble.json(BackendDouble.userJson());
        }
        return BackendDouble.sessionResponse();
      });
      await backend.signIn();
      await SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).updatePassword('N3wPassw0rd');
      final request = backend.to('/user').single;
      expect(request.method, 'PUT');
      expect(body(request)['password'], 'N3wPassw0rd');
    });

    test('the same password again is samePassword', () async {
      final backend = BackendDouble((request) async {
        if (request.url.path.endsWith('/user')) {
          return BackendDouble.authError(422, 'same_password');
        }
        return BackendDouble.sessionResponse();
      });
      await backend.signIn();
      final result = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      ).updatePassword('same');
      expect(
        await failureOf(result),
        const AuthFailure(AuthFailureReason.samePassword),
      );
    });
  });

  group('signOut', () {
    test('clears the saved Home, whatever the reason', () async {
      final backend = BackendDouble((request) async {
        if (request.url.path.endsWith('/logout')) return http.Response('', 204);
        return BackendDouble.sessionResponse();
      });
      await backend.signIn();
      snapshots.values['feed_u1'] = '{}';
      final datasource = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      );

      await datasource.signOut();
      await Future<void>.delayed(Duration.zero);

      expect(snapshots.values, isEmpty);
      await datasource.dispose();
    });

    test('this device only, by default', () async {
      final backend = BackendDouble((request) async {
        if (request.url.path.endsWith('/logout')) return http.Response('', 204);
        return BackendDouble.sessionResponse();
      });
      await backend.signIn();
      final datasource = SupabaseAuthDatasource(
        backend.client,
        tracker,
        snapshots,
      );

      await datasource.signOut();
      expect(
        backend.to('/logout').single.url.queryParameters['scope'],
        'local',
      );
      expect(datasource.hasSession, isFalse);
    });

    test(
      'every other device with others: true, keeping this one signed in',
      () async {
        final backend = BackendDouble((request) async {
          if (request.url.path.endsWith('/logout')) {
            return http.Response('', 204);
          }
          return BackendDouble.sessionResponse();
        });
        await backend.signIn();
        final datasource = SupabaseAuthDatasource(
          backend.client,
          tracker,
          snapshots,
        );

        await datasource.signOut(others: true);
        expect(
          backend.to('/logout').single.url.queryParameters['scope'],
          'others',
        );
        expect(datasource.hasSession, isTrue);
      },
    );
  });

  test('without a session there is no email', () {
    final datasource = SupabaseAuthDatasource(
      BackendDouble((_) async => BackendDouble.json({})).client,
      tracker,
      snapshots,
    );
    expect(datasource.hasSession, isFalse);
    expect(datasource.currentEmail, isNull);
  });

  group('recoveryActive', () {
    BackendDouble backend() => BackendDouble((request) async {
      if (request.url.path.endsWith('/logout')) return http.Response('', 204);
      if (request.url.path.endsWith('/user')) {
        return BackendDouble.json(BackendDouble.userJson());
      }
      return BackendDouble.sessionResponse();
    });

    test('needs a session, not just the pending flag', () async {
      await storage.setValue<bool>(StorageKeys.recoveryPending, true);
      expect(
        SupabaseAuthDatasource(
          backend().client,
          tracker,
          snapshots,
        ).recoveryActive,
        isFalse,
      );
    });

    test('a session without the flag is an ordinary session', () async {
      final double = backend();
      await double.signIn();
      expect(
        SupabaseAuthDatasource(
          double.client,
          tracker,
          snapshots,
        ).recoveryActive,
        isFalse,
      );
    });

    test('is on with a session and the flag, and ends on sign-out', () async {
      final double = backend();
      await double.signIn();
      await storage.setValue<bool>(StorageKeys.recoveryPending, true);
      final datasource = SupabaseAuthDatasource(
        double.client,
        tracker,
        snapshots,
      );
      expect(datasource.recoveryActive, isTrue);

      await datasource.signOut();
      expect(datasource.recoveryActive, isFalse);
      expect(storage.getValue<bool>(StorageKeys.recoveryPending), isNull);
    });

    test('ends when the new password is set', () async {
      final double = backend();
      await double.signIn();
      await storage.setValue<bool>(StorageKeys.recoveryPending, true);
      final datasource = SupabaseAuthDatasource(
        double.client,
        tracker,
        snapshots,
      );

      await datasource.updatePassword('Password1');
      expect(datasource.recoveryActive, isFalse);
    });
  });

  group('recovery and session events', () {
    BackendDouble backend() => BackendDouble((request) async {
      if (request.url.path.endsWith('/logout')) return http.Response('', 204);
      return BackendDouble.sessionResponse();
    });

    /// What gotrue does when the reset link is opened: emit `passwordRecovery`.
    void openLink(BackendDouble double) =>
        double.client.auth.notifyAllSubscribers(
          AuthChangeEvent.passwordRecovery,
          broadcast: false,
        );

    /// Lets the datasource's own subscription and the tracker's microtasks run.
    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('a link opened before anyone listens reaches the listeners that join first, once each', () async {
      final double = backend();
      await double.signIn();
      final datasource = SupabaseAuthDatasource(
        double.client,
        tracker,
        snapshots,
      );
      openLink(double);
      await settle();

      final first = <RecoverySignal>[];
      final second = <RecoverySignal>[];
      final a = datasource.recoverySignals.listen(first.add);
      final b = datasource.recoverySignals.listen(second.add);
      await settle();

      // Both listeners were attached when it was delivered: one copy each, never two for the same one.
      expect(first, [RecoverySignal.started]);
      expect(second, [RecoverySignal.started]);
      expect(datasource.recoveryActive, isTrue);
      await a.cancel();
      await b.cancel();
      await datasource.dispose();
    });

    test(
      'a link handled before the datasource existed is still seen',
      () async {
        final double = backend();
        await double.signIn();
        openLink(
          double,
        ); // gotrue replays this to the datasource's subscription
        final datasource = SupabaseAuthDatasource(
          double.client,
          tracker,
          snapshots,
        );
        await settle();

        final signals = <RecoverySignal>[];
        final sub = datasource.recoverySignals.listen(signals.add);
        await settle();

        expect(signals, [RecoverySignal.started]);
        await sub.cancel();
        await datasource.dispose();
      },
    );

    test('two live listeners each get the event once', () async {
      final double = backend();
      await double.signIn();
      final datasource = SupabaseAuthDatasource(
        double.client,
        tracker,
        snapshots,
      );
      final first = <RecoverySignal>[];
      final second = <RecoverySignal>[];
      final a = datasource.recoverySignals.listen(first.add);
      final b = datasource.recoverySignals.listen(second.add);

      openLink(double);
      await settle();

      expect(first, [RecoverySignal.started]);
      expect(second, [RecoverySignal.started]);
      await a.cancel();
      await b.cancel();
      await datasource.dispose();
    });

    test('an old link is not replayed to a listener that comes after it was delivered', () async {
      final double = backend();
      await double.signIn();
      final datasource = SupabaseAuthDatasource(
        double.client,
        tracker,
        snapshots,
      );
      final early = datasource.recoverySignals.listen((_) {});
      openLink(double);
      await settle();
      await early.cancel();

      final late = <RecoverySignal>[];
      final sub = datasource.recoverySignals.listen(late.add);
      await settle();

      expect(late, isEmpty);
      await sub.cancel();
      await datasource.dispose();
    });

    test('signing out drops a recovery that was never delivered', () async {
      final double = backend();
      await double.signIn();
      final datasource = SupabaseAuthDatasource(
        double.client,
        tracker,
        snapshots,
      );
      openLink(double);
      await settle();
      await datasource.signOut();

      final signals = <RecoverySignal>[];
      final sub = datasource.recoverySignals.listen(signals.add);
      await settle();

      expect(signals, isEmpty);
      expect(datasource.recoveryActive, isFalse);
      await sub.cancel();
      await datasource.dispose();
    });

    test('an expired or refused link is linkFailed', () async {
      final double = backend();
      final datasource = SupabaseAuthDatasource(
        double.client,
        tracker,
        snapshots,
      );
      final signals = <RecoverySignal>[];
      final sub = datasource.recoverySignals.listen(signals.add);

      double.client.auth.notifyException(
        AuthException('expired', statusCode: 'otp_expired'),
      );
      double.client.auth.notifyException(
        AuthException('denied', code: 'access_denied'),
      );
      await settle();

      expect(signals, [RecoverySignal.linkFailed, RecoverySignal.linkFailed]);
      expect(datasource.recoveryActive, isFalse);
      await sub.cancel();
      await datasource.dispose();
    });

    test('other stream errors are not about the link', () async {
      final double = backend();
      final datasource = SupabaseAuthDatasource(
        double.client,
        tracker,
        snapshots,
      );
      final signals = <RecoverySignal>[];
      final sub = datasource.recoverySignals.listen(signals.add);

      double.client.auth.notifyException(
        AuthRetryableFetchException(message: 'offline'),
      );
      double.client.auth.notifyException(StateError('boom'));
      await settle();

      expect(signals, isEmpty);
      await sub.cancel();
      await datasource.dispose();
    });

    test('a refused link that arrives before any listener is kept for the first one', () async {
      final double = backend();
      final datasource = SupabaseAuthDatasource(
        double.client,
        tracker,
        snapshots,
      );
      double.client.auth.notifyException(
        AuthException('expired', statusCode: 'otp_expired'),
      );
      await settle();

      final signals = <RecoverySignal>[];
      final sub = datasource.recoverySignals.listen(signals.add);
      await settle();

      expect(signals, [RecoverySignal.linkFailed]);
      await sub.cancel();
      await datasource.dispose();
    });

    test('signing in ends a pending recovery', () async {
      final double = BackendDouble((request) async {
        if (request.url.path.endsWith('/functions/v1/sign-in')) {
          return BackendDouble.json({'refresh_token': 'refresh'});
        }
        return BackendDouble.sessionResponse();
      });
      await storage.setValue<bool>(StorageKeys.recoveryPending, true);
      final datasource = SupabaseAuthDatasource(
        double.client,
        tracker,
        snapshots,
      );

      await datasource.signIn(identifier: 'dip.roy', password: 'secret');

      expect(storage.getValue<bool>(StorageKeys.recoveryPending), isNull);
      expect(datasource.recoveryActive, isFalse);
      await datasource.dispose();
    });

    test(
      'a session lost by itself is reported as expired; an own sign-out is not',
      () async {
        final double = backend();
        await double.signIn();
        final datasource = SupabaseAuthDatasource(
          double.client,
          tracker,
          snapshots,
        );
        final ended = <SignedOutReason>[];
        final sub = datasource.sessionEnded.listen(ended.add);

        await datasource.signOut(); // userInitiated
        double.client.auth.notifyAllSubscribers(
          AuthChangeEvent.signedOut,
          broadcast: false,
          signOutReason: SignOutReason.sessionExpired,
        );
        await settle();

        expect(ended, [SignedOutReason.expired]);
        await sub.cancel();
        await datasource.dispose();
      },
    );

    test(
      'a session lost before the app shell listens still reaches it',
      () async {
        final double = backend();
        await double.signIn();
        final datasource = SupabaseAuthDatasource(
          double.client,
          tracker,
          snapshots,
        );
        double.client.auth.notifyAllSubscribers(
          AuthChangeEvent.signedOut,
          broadcast: false,
          signOutReason: SignOutReason.sessionExpired,
        );
        await settle();

        final ended = <SignedOutReason>[];
        final sub = datasource.sessionEnded.listen(ended.add);
        await settle();

        expect(ended, [SignedOutReason.expired]);
        await sub.cancel();
        await datasource.dispose();
      },
    );

    test('dispose can be called twice', () async {
      final datasource = SupabaseAuthDatasource(
        backend().client,
        tracker,
        snapshots,
      );
      await datasource.dispose();
      await datasource.dispose();
    });

    test('dispose stops the datasource from reacting to auth events', () async {
      final double = backend();
      await double.signIn();
      final datasource = SupabaseAuthDatasource(
        double.client,
        tracker,
        snapshots,
      );
      await datasource.dispose();

      openLink(double);
      await settle();

      expect(storage.getValue<bool>(StorageKeys.recoveryPending), isNull);
    });
  });
}
