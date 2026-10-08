import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/error/guard.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  Future<Failure?> failureOf(Object error) async {
    final result = await Guard.run<int>(() async => throw error);
    return result.fold((f) => f, (_) => null);
  }

  test('a value comes back as a Right', () async {
    expect(await Guard.run(() async => 5), const Right<Failure, int>(5));
  });

  group('app exceptions', () {
    test('AuthRejectedException keeps its reason', () async {
      expect(
        await failureOf(
          const AuthRejectedException(AuthFailureReason.emailTaken),
        ),
        const AuthFailure(AuthFailureReason.emailTaken),
      );
    });

    test('NotFoundException, TimeoutException', () async {
      expect(
        await failureOf(const NotFoundException()),
        const NotFoundFailure(),
      );
      expect(await failureOf(TimeoutException('slow')), const TimeoutFailure());
    });

    test('a parse error is a ParseFailure', () async {
      expect(
        await failureOf(const FormatException('bad')),
        const ParseFailure(),
      );
    });

    test('an unknown error is an UnexpectedFailure', () async {
      expect(await failureOf(StateError('bug')), const UnexpectedFailure());
    });
  });

  group('Supabase auth errors', () {
    final cases = <String, AuthFailureReason>{
      'invalid_credentials': AuthFailureReason.invalidCredentials,
      'email_not_confirmed': AuthFailureReason.emailNotConfirmed,
      'user_already_exists': AuthFailureReason.emailTaken,
      'email_exists': AuthFailureReason.emailTaken,
      'otp_expired': AuthFailureReason.invalidCode,
      'weak_password': AuthFailureReason.weakPassword,
      'same_password': AuthFailureReason.samePassword,
      'over_email_send_rate_limit': AuthFailureReason.rateLimited,
      'over_request_rate_limit': AuthFailureReason.rateLimited,
      'session_not_found': AuthFailureReason.sessionExpired,
      'refresh_token_not_found': AuthFailureReason.sessionExpired,
    };
    cases.forEach((code, reason) {
      test('$code -> $reason', () async {
        expect(
          await failureOf(AuthApiException('m', statusCode: '400', code: code)),
          AuthFailure(reason),
        );
      });
    });

    test('an unknown code is a ServerFailure with the status', () async {
      expect(
        await failureOf(
          AuthApiException('m', statusCode: '500', code: 'weird'),
        ),
        const ServerFailure(statusCode: 500),
      );
    });

    test('a missing session is sessionExpired', () async {
      expect(
        await failureOf(AuthSessionMissingException()),
        const AuthFailure(AuthFailureReason.sessionExpired),
      );
    });

    test('a retryable fetch error is a NetworkFailure', () async {
      expect(
        await failureOf(AuthRetryableFetchException(message: 'offline')),
        const NetworkFailure(),
      );
    });
  });

  group('the sign-in function', () {
    FunctionException fn(int status, Object? details) =>
        FunctionException(status: status, details: details);

    test('401 invalid_credentials', () async {
      expect(
        await failureOf(fn(401, {'code': 'invalid_credentials'})),
        const AuthFailure(AuthFailureReason.invalidCredentials),
      );
    });

    test('403 email_not_confirmed carries the email', () async {
      expect(
        await failureOf(
          fn(403, {'code': 'email_not_confirmed', 'email': 'a@b.co'}),
        ),
        const AuthFailure(AuthFailureReason.emailNotConfirmed, email: 'a@b.co'),
      );
    });

    test('429 rate_limited carries retryAfter', () async {
      expect(
        await failureOf(fn(429, {'code': 'rate_limited', 'retry_after': 42})),
        const AuthFailure(
          AuthFailureReason.tooManyAttempts,
          retryAfter: Duration(seconds: 42),
        ),
      );
    });

    test('email and retryAfter are null for every other reason', () async {
      final others = {'invalid_credentials': 401};
      for (final entry in others.entries) {
        final failure = await failureOf(
          fn(entry.value, {'code': entry.key}),
        ) as AuthFailure;
        expect(failure.email, isNull, reason: entry.key);
        expect(failure.retryAfter, isNull, reason: entry.key);
      }
      for (final reason in AuthFailureReason.values) {
        final failure = AuthFailure(reason);
        expect(failure.email, isNull);
        expect(failure.retryAfter, isNull);
      }
      // Supabase Auth's own errors never set them either.
      final auth = await failureOf(
        AuthApiException(
          'm',
          statusCode: '400',
          code: 'over_request_rate_limit',
        ),
      ) as AuthFailure;
      expect(auth.reason, AuthFailureReason.rateLimited);
      expect(auth.email, isNull);
      expect(auth.retryAfter, isNull);
    });

    test('a transport failure is a NetworkFailure', () async {
      expect(
        await failureOf(FunctionsFetchException(details: 'offline')),
        const NetworkFailure(),
      );
    });

    test('an unknown answer or a 500 is a ServerFailure', () async {
      expect(
        await failureOf(fn(500, {'code': 'server_error'})),
        const ServerFailure(statusCode: 500),
      );
      expect(
        await failureOf(fn(400, 'not json')),
        const ServerFailure(statusCode: 400),
      );
    });
  });

  group('Postgrest, storage and network errors', () {
    test('unique violation -> ConflictFailure', () async {
      expect(
        await failureOf(
          const PostgrestException(message: 'dup', code: '23505'),
        ),
        const ConflictFailure(),
      );
    });

    test('no row -> NotFoundFailure', () async {
      expect(
        await failureOf(
          const PostgrestException(message: 'x', code: 'PGRST116'),
        ),
        const NotFoundFailure(),
      );
    });

    test('expired JWT and not authenticated -> sessionExpired', () async {
      for (final code in ['PGRST301', '42501']) {
        expect(
          await failureOf(PostgrestException(message: 'x', code: code)),
          const AuthFailure(AuthFailureReason.sessionExpired),
        );
      }
    });

    test('other Postgrest errors are a ServerFailure', () async {
      expect(
        await failureOf(const PostgrestException(message: 'x', code: '500')),
        const ServerFailure(statusCode: 500),
      );
    });

    test('storage error keeps the status', () async {
      expect(
        await failureOf(const StorageException('x', statusCode: '413')),
        const ServerFailure(statusCode: 413),
      );
    });

    test('socket and http client errors are a NetworkFailure', () async {
      expect(
        await failureOf(const SocketException('down')),
        const NetworkFailure(),
      );
      expect(
        await failureOf(http.ClientException('down')),
        const NetworkFailure(),
      );
    });
  });
}
