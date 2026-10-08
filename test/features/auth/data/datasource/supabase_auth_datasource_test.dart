import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/constants/app_config.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/auth/data/datasource/auth_datasource.dart';

import '../../../../helpers/backend_double.dart';

void main() {
  Failure? failureOf(Either<Failure, Object?> result) =>
      result.fold((f) => f, (_) => null);

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

      final result = await datasource.signIn(
        identifier: ' dip.roy ',
        password: 'secret',
      );

      expect(result, const Right<Failure, Unit>(unit));
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

        final result = await datasource.signIn(
          identifier: 'nobody',
          password: 'x',
        );

        expect(
          failureOf(result),
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
        final result = await SupabaseAuthDatasource(backend.client)
            .signIn(identifier: 'dip.roy', password: 'x');

        final failure = failureOf(result)! as AuthFailure;
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
      final result = await SupabaseAuthDatasource(backend.client)
          .signIn(identifier: 'dip.roy', password: 'x');

      final failure = failureOf(result)! as AuthFailure;
      expect(failure.reason, AuthFailureReason.tooManyAttempts);
      expect(failure.retryAfter, const Duration(seconds: 897));
      expect(failure.email, isNull);
    });

    test('a server error is a ServerFailure', () async {
      final backend = signInBackend(
        function: BackendDouble.json({'code': 'server_error'}, status: 500),
      );
      final result = await SupabaseAuthDatasource(backend.client)
          .signIn(identifier: 'a@b.co', password: 'x');
      expect(failureOf(result), const ServerFailure(statusCode: 500));
    });

    test('an answer without a refresh token is a ParseFailure', () async {
      final backend = signInBackend(function: BackendDouble.json({'ok': true}));
      final result = await SupabaseAuthDatasource(backend.client)
          .signIn(identifier: 'a@b.co', password: 'x');
      expect(failureOf(result), const ParseFailure());
    });

    test('offline is a NetworkFailure', () async {
      final backend = signInBackend(throwing: http.ClientException('offline'));
      final result = await SupabaseAuthDatasource(backend.client)
          .signIn(identifier: 'a@b.co', password: 'x');
      expect(failureOf(result), const NetworkFailure());
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
      final result = await SupabaseAuthDatasource(backend.client)
          .signUp(email: 'new@example.com', password: 'Passw0rd!');
      expect(result.isRight, isTrue);
      expect(body(backend.to('/signup').single)['email'], 'new@example.com');
    });

    test(
      'an existing address (a user with no identities) is emailTaken',
      () async {
        final backend = BackendDouble(
          (_) async =>
              BackendDouble.json(BackendDouble.userJson(identities: [])),
        );
        final result = await SupabaseAuthDatasource(backend.client)
            .signUp(email: 'taken@example.com', password: 'Passw0rd!');
        expect(
          failureOf(result),
          const AuthFailure(AuthFailureReason.emailTaken),
        );
      },
    );

    test('a weak password is weakPassword', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.authError(422, 'weak_password'),
      );
      final result = await SupabaseAuthDatasource(backend.client)
          .signUp(email: 'a@b.co', password: '1');
      expect(
        failureOf(result),
        const AuthFailure(AuthFailureReason.weakPassword),
      );
    });
  });

  group('verify and resend', () {
    test('a correct code posts a signup verification', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.sessionResponse(),
      );
      final result = await SupabaseAuthDatasource(backend.client)
          .verifySignUpCode(email: 'dip@example.com', code: '123456');
      expect(result.isRight, isTrue);
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
      final result = await SupabaseAuthDatasource(backend.client)
          .verifySignUpCode(email: 'dip@example.com', code: '000000');
      expect(
        failureOf(result),
        const AuthFailure(AuthFailureReason.invalidCode),
      );
    });

    test('resend asks for a new signup code', () async {
      final backend = BackendDouble((_) async => BackendDouble.json({}));
      final result = await SupabaseAuthDatasource(backend.client)
          .resendSignUpCode('dip@example.com');
      expect(result.isRight, isTrue);
      expect(
        body(backend.to('/resend').single),
        containsPair('type', 'signup'),
      );
    });

    test('too many emails is rateLimited', () async {
      final backend = BackendDouble(
        (_) async => BackendDouble.authError(429, 'over_email_send_rate_limit'),
      );
      final result = await SupabaseAuthDatasource(backend.client)
          .resendSignUpCode('a@b.co');
      expect(
        failureOf(result),
        const AuthFailure(AuthFailureReason.rateLimited),
      );
    });
  });

  group('password reset', () {
    test('the reset email links back to the app', () async {
      final backend = BackendDouble((_) async => BackendDouble.json({}));
      final result = await SupabaseAuthDatasource(backend.client)
          .sendPasswordReset(' dip@example.com ');
      expect(result.isRight, isTrue);
      final request = backend.to('/recover').single;
      expect(
        request.url.queryParameters['redirect_to'],
        AppConfig.recoveryRedirectUrl,
      );
      expect(body(request)['email'], 'dip@example.com');
    });

    test('updatePassword puts the new password on the user', () async {
      final backend = BackendDouble((request) async {
        if (request.url.path.endsWith('/user')) {
          return BackendDouble.json(BackendDouble.userJson());
        }
        return BackendDouble.sessionResponse();
      });
      await backend.signIn();
      final result = await SupabaseAuthDatasource(backend.client)
          .updatePassword('N3wPassw0rd');
      expect(result.isRight, isTrue);
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
      final result = await SupabaseAuthDatasource(backend.client)
          .updatePassword('same');
      expect(
        failureOf(result),
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

      final result = await datasource.signOut();

      expect(result.isRight, isTrue);
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

        final result = await datasource.signOut(others: true);

        expect(result.isRight, isTrue);
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
