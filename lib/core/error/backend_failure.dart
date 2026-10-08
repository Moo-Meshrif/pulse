import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../enums/auth_failure_reason.dart';
import 'failures.dart';

/// Maps Supabase's exceptions to [Failure]s; returns null for anything it does not recognise.
/// The one file that knows Supabase's error shapes: a REST backend replaces it.
Failure? backendFailure(Object error) => switch (error) {
  AuthRetryableFetchException() => const NetworkFailure(),
  AuthSessionMissingException() => const AuthFailure(
    AuthFailureReason.sessionExpired,
  ),
  AuthException() => _auth(error),
  FunctionsFetchException() => const NetworkFailure(),
  FunctionException() => _function(error),
  PostgrestException() => _postgrest(error),
  StorageException() => ServerFailure(
    statusCode: int.tryParse(error.statusCode ?? ''),
  ),
  SocketException() || http.ClientException() => const NetworkFailure(),
  _ => null,
};

Failure _auth(AuthException error) {
  final reason = switch (error.code) {
    'invalid_credentials' => AuthFailureReason.invalidCredentials,
    'email_not_confirmed' => AuthFailureReason.emailNotConfirmed,
    'user_already_exists' || 'email_exists' => AuthFailureReason.emailTaken,
    'otp_expired' || 'invalid_otp' => AuthFailureReason.invalidCode,
    'weak_password' => AuthFailureReason.weakPassword,
    'same_password' => AuthFailureReason.samePassword,
    'over_email_send_rate_limit' ||
    'over_request_rate_limit' ||
    'over_sms_send_rate_limit' => AuthFailureReason.rateLimited,
    'session_not_found' ||
    'session_expired' ||
    'refresh_token_not_found' ||
    'refresh_token_already_used' ||
    'bad_jwt' => AuthFailureReason.sessionExpired,
    _ => null,
  };
  if (reason != null) return AuthFailure(reason);
  if (error is AuthWeakPasswordException) {
    return const AuthFailure(AuthFailureReason.weakPassword);
  }
  return ServerFailure(statusCode: int.tryParse(error.statusCode ?? ''));
}

/// The `sign-in` Edge Function's answers: `{"code": ...}` plus `email` (403) or `retry_after` seconds
/// (429). Anything else is a server error.
Failure _function(FunctionException error) {
  final details = error.details;
  final body = details is Map ? details : const <String, Object?>{};
  return switch ((error.status, body['code'])) {
    (401, 'invalid_credentials') => const AuthFailure(
      AuthFailureReason.invalidCredentials,
    ),
    (403, 'email_not_confirmed') => AuthFailure(
      AuthFailureReason.emailNotConfirmed,
      email: body['email'] is String ? body['email'] as String : null,
    ),
    (429, 'rate_limited') => AuthFailure(
      AuthFailureReason.tooManyAttempts,
      retryAfter: Duration(
        seconds: body['retry_after'] is num
            ? (body['retry_after'] as num).toInt()
            : 60,
      ),
    ),
    _ => ServerFailure(statusCode: error.status),
  };
}

Failure _postgrest(PostgrestException error) => switch (error.code) {
  '23505' => const ConflictFailure(), // unique violation (a taken username)
  'PGRST301' || 'PGRST303' => const AuthFailure(
    AuthFailureReason.sessionExpired,
  ), // expired or invalid JWT
  'PGRST116' => const NotFoundFailure(), // .single() matched no row
  '42501' => const AuthFailure(
    AuthFailureReason.sessionExpired,
  ), // not authenticated
  _ => ServerFailure(statusCode: int.tryParse(error.code ?? '')),
};
