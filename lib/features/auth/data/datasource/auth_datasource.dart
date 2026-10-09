import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/either.dart';

/// Authentication, as an interface because the backend will change (Supabase now, REST later). Every call
/// returns a [Result], never throws.
abstract interface class AuthDatasource {
  /// A session is stored on this device (it may still be expired until the next request).
  bool get hasSession;

  /// The signed-in user's email, or the recovery session's email on the reset screen.
  String? get currentEmail;

  /// Emits whenever the app is opened from a password-recovery link (the reset screen's session).
  Stream<Unit> get passwordRecovery;

  /// [identifier] is an email, or a username (anything without an "@"). Wrong password and unknown username
  /// are the same `AuthFailure(invalidCredentials)`; `emailNotConfirmed` is returned only after the right
  /// password.
  Future<Result<Unit>> signIn({
    required String identifier,
    required String password,
  });

  /// Creates the account and emails the 6-digit code. An email that already has an account is
  /// `AuthFailure(emailTaken)`.
  Future<Result<Unit>> signUp({
    required String email,
    required String password,
  });

  Future<Result<Unit>> verifySignUpCode({
    required String email,
    required String code,
  });

  Future<Result<Unit>> resendSignUpCode(String email);

  /// Emails the password-reset link.
  Future<Result<Unit>> sendPasswordReset(String email);

  Future<Result<Unit>> updatePassword(String newPassword);

  /// Signs out this device, or every other device when [others] is true (this one stays signed in).
  Future<Result<Unit>> signOut({bool others = false});
}

/// [AuthDatasource] as an adapter over Supabase Auth, with sign-in going through the `sign-in` Edge
/// Function (throttled, same answer for unknown user and wrong password).
@LazySingleton(as: AuthDatasource)
final class SupabaseAuthDatasource implements AuthDatasource {
  SupabaseAuthDatasource(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  bool get hasSession => _auth.currentSession != null;

  @override
  String? get currentEmail => _auth.currentUser?.email;

  @override
  Stream<Unit> get passwordRecovery => _auth.onAuthStateChange
      .where((state) => state.event == AuthChangeEvent.passwordRecovery)
      .map((_) => unit);

  @override
  Future<Result<Unit>> signIn({
    required String identifier,
    required String password,
  }) => Guard.run(() async {
    // The Edge Function checks the password (and resolves a username) server-side, so the app never
    // learns an account's email before a correct password. It answers with tokens only.
    final response = await _client.functions.invoke(
      'sign-in',
      body: {'identifier': identifier.trim(), 'password': password},
    );
    final data = response.data;
    final refreshToken = data is Map ? data['refresh_token'] : null;
    if (refreshToken is! String || refreshToken.isEmpty) {
      throw const FormatException('sign-in answered without a refresh token');
    }
    await _auth.setSession(refreshToken);
    return unit;
  });

  @override
  Future<Result<Unit>> signUp({
    required String email,
    required String password,
  }) => Guard.run(() async {
    final response = await _auth.signUp(
      email: email.trim(),
      password: password,
    );
    // With email confirmation on, Supabase answers an existing address with a user that has no
    // identities (instead of an error, so it does not reveal which emails are registered).
    if (response.user?.identities?.isEmpty ?? false) {
      throw const AuthRejectedException(AuthFailureReason.emailTaken);
    }
    return unit;
  });

  @override
  Future<Result<Unit>> verifySignUpCode({
    required String email,
    required String code,
  }) => Guard.run(() async {
    await _auth.verifyOTP(
      type: OtpType.signup,
      email: email.trim(),
      token: code,
    );
    return unit;
  });

  @override
  Future<Result<Unit>> resendSignUpCode(String email) => Guard.run(() async {
    await _auth.resend(type: OtpType.signup, email: email.trim());
    return unit;
  });

  @override
  Future<Result<Unit>> sendPasswordReset(String email) => Guard.run(() async {
    // Supabase answers success for an unknown email, so ask the database first.
    final exists = await _client.rpc<bool>(
      'email_exists',
      params: {'p_email': email.trim()},
    );
    if (!exists) {
      throw const AuthRejectedException(AuthFailureReason.accountNotFound);
    }
    await _auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: AppConfig.recoveryRedirectUrl,
    );
    return unit;
  });

  @override
  Future<Result<Unit>> updatePassword(String newPassword) =>
      Guard.run(() async {
        await _auth.updateUser(UserAttributes(password: newPassword));
        return unit;
      });

  @override
  Future<Result<Unit>> signOut({bool others = false}) => Guard.run(() async {
    await _auth.signOut(
      scope: others ? SignOutScope.others : SignOutScope.local,
    );
    return unit;
  });
}
