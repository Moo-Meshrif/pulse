import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/constants/app_config.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/auth/data/datasource/auth_datasource.dart';

import '../../../../helpers/backend_double.dart';

void main() {
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
      final datasource = SupabaseAuthDatasource(backend.client);

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

    test('never calls the username RPC or a password grant', () async {
      final backend = signInBackend();
      await SupabaseAuthDatasource(backend.client)
          .signIn(identifier: 'dip.roy', password: 'secret');

      expect(backend.to('get_email_for_username'), isEmpty);
      expect(
        backend.to('/token').map((r) => r.url.queryParameters['grant_type']),
        isNot(contains('password')),
      );
      expect(
        backend.requests.where((r) => r.url.path.contains('/rpc/')),
        isEmpty,
      );
    });

    test(
      'a wrong password or unknown user is invalidCredentials, no session',
      () async {
        final backend = signInBackend(
          function: BackendDouble.json({
            'code': 'invalid_credentials',
          }, status: 401),
        );
        final datasource = SupabaseAuthDatasource(backend.client);

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
        final result = SupabaseAuthDatasource(backend.client)
            .signIn(identifier: 'dip.roy', password: 'x');

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
      final result = SupabaseAuthDatasource(backend.client)
          .signIn(identifier: 'dip.roy', password: 'x');

      final failure = (await failureOf(result))! as AuthFailure;
      expect(failure.reason, AuthFailureReason.tooManyAttempts);
      expect(failure.retryAfter, const Duration(seconds: 897));
      expect(failure.email, isNull);
    });

    test('a server error is a ServerFailure', () async {
      final backend = signInBackend(
        function: BackendDouble.json({'code': 'server_error'}, status: 500),
      );
      final result = SupabaseAuthDatasource(backend.client)
          .signIn(identifier: 'a@b.co', password: 'x');
      expect(await failureOf(result), const ServerFailure(statusCode: 500));
    });

    test('an answer without a refresh token is a ParseFailure', () async {
      final backend = signInBackend(function: BackendDouble.json({'ok': true}));
      final result = SupabaseAuthDatasource(backend.client)
          .signIn(identifier: 'a@b.co', password: 'x');
      expect(await failureOf(result), const ParseFailure());
    });

    test('offline is a NetworkFailure', () async {
      final backend = signInBackend(throwing: http.ClientException('offline'));
      final result = SupabaseAuthDatasource(backend.client)
          .signIn(identifier: 'a@b.co', password: 'x');
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
      await SupabaseAuthDatasource(backend.client)
          .signUp(email: 'new@example.com', password: 'Passw0rd!');
      expect(body(backend.to('/signup').single)['email'], 'new@example.com');
    });

    test(
      'an existing address (a user with no identities) is emailTaken',
      () async {
        final backend = BackendDouble(
          (_) async =>
              BackendDouble.json(BackendDouble.userJson(identities: [])),
        );
        final result = SupabaseAuthDatasource(backend.client)
            .signUp(email: 'taken@example.com', password: 'Passw0rd!');
        expect(
          await failureOf(result),
          const AuthFailure(AuthFailureReason.emailTaken),
        );
      },
    );

    test('a weak password is weakPassword', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.authError(422, 'weak_password'),
      );
      final result = SupabaseAuthDatasource(backend.client)
          .signUp(email: 'a@b.co', password: '1');
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
      await SupabaseAuthDatasource(backend.client)
          .verifySignUpCode(email: 'dip@example.com', code: '123456');
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
      final result = SupabaseAuthDatasource(backend.client)
          .verifySignUpCode(email: 'dip@example.com', code: '000000');
      expect(
        await failureOf(result),
        const AuthFailure(AuthFailureReason.invalidCode),
      );
    });

    test('resend asks for a new signup code', () async {
      final backend = BackendDouble((_) async => BackendDouble.json({}));
      await SupabaseAuthDatasource(backend.client)
          .resendSignUpCode('dip@example.com');
      expect(
        body(backend.to('/resend').single),
        containsPair('type', 'signup'),
      );
    });

    test('too many emails is rateLimited', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.authError(429, 'over_email_send_rate_limit'),
      );
      final result = SupabaseAuthDatasource(backend.client)
          .resendSignUpCode('a@b.co');
      expect(
        await failureOf(result),
        const AuthFailure(AuthFailureReason.rateLimited),
      );
    });
  });

  group('password reset', () {
    test('the reset email links back to the app', () async {
      final backend = BackendDouble(
        (request) async => request.url.path.endsWith('/rpc/email_exists')
            ? BackendDouble.json(true)
            : BackendDouble.json({}),
      );
      await SupabaseAuthDatasource(backend.client)
          .sendPasswordReset(' dip@example.com ');
      final request = backend.to('/recover').single;
      expect(
        request.url.queryParameters['redirect_to'],
        AppConfig.recoveryRedirectUrl,
      );
      expect(body(request)['email'], 'dip@example.com');
    });

    test('an email with no account is refused and nothing is sent', () async {
      final backend = BackendDouble(
        (request) async => request.url.path.endsWith('/rpc/email_exists')
            ? BackendDouble.json(false)
            : BackendDouble.json({}),
      );
      final result = SupabaseAuthDatasource(backend.client)
          .sendPasswordReset('ghost@example.com');
      expect(
        await failureOf(result),
        isA<AuthFailure>().having(
          (f) => f.reason,
          'reason',
          AuthFailureReason.accountNotFound,
        ),
      );
      expect(backend.to('/recover'), isEmpty);
    });

    test('updatePassword puts the new password on the user', () async {
      final backend = BackendDouble((request) async {
        if (request.url.path.endsWith('/user')) {
          return BackendDouble.json(BackendDouble.userJson());
        }
        return BackendDouble.sessionResponse();
      });
      await backend.signIn();
      await SupabaseAuthDatasource(backend.client)
          .updatePassword('N3wPassw0rd');
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
      final result = SupabaseAuthDatasource(backend.client)
          .updatePassword('same');
      expect(
        await failureOf(result),
        const AuthFailure(AuthFailureReason.samePassword),
      );
    });
  });

  group('signOut', () {
    test('this device only, by default', () async {
      final backend = BackendDouble((request) async {
        if (request.url.path.endsWith('/logout')) return http.Response('', 204);
        return BackendDouble.sessionResponse();
      });
      await backend.signIn();
      final datasource = SupabaseAuthDatasource(backend.client);

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
        final datasource = SupabaseAuthDatasource(backend.client);

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
    );
    expect(datasource.hasSession, isFalse);
    expect(datasource.currentEmail, isNull);
  });
}
