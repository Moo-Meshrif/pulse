import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/enums/recovery_signal.dart';
import '../../../../core/enums/signed_out_reason.dart';
import '../../../../core/error/guard.dart';
import 'password_recovery_tracker.dart';

/// Authentication, as an interface because the backend can change (Supabase now, Firebase or REST later).
/// Every async call throws a `Failure` on error.
abstract interface class AuthDatasource {
  /// A session is stored on this device (it may still be expired until the next request). Read
  /// synchronously by the splash, so an adapter must have restored its session before `runApp`.
  bool get hasSession;

  /// The signed-in user's email, or the recovery session's email on the reset screen.
  String? get currentEmail;

  /// A password-recovery session is open on this device and its new password is not set yet. It outlives
  /// the app (a closed reset screen must not leave a signed-in session behind), and ends when the password
  /// is changed, the user signs in or out, or the session is gone.
  bool get recoveryActive;

  /// Only the app shell may listen. The stream can replay earlier expiries, so a second listener could
  /// start a second logout flow. The shell needs the replay: a session rejected during start-up still
  /// reaches it.
  ///
  /// Emits when the session ended by itself (the backend rejected its refresh credentials), never when the
  /// app signed out. The device cannot tell an old session from a revoked one here, so it says
  /// [SignedOutReason.expired]; a request that fails with `AuthFailure(sessionRevoked)` knows better.
  Stream<SignedOutReason> get sessionEnded;

  /// What opening the emailed reset link did. A signal that arrives before anyone listens (the link
  /// started the app) is kept for the next listener, once; older ones are never replayed. After a restart
  /// use [recoveryActive] instead.
  Stream<RecoverySignal> get recoverySignals;

  /// [identifier] is an email, or a username (anything without an "@").
  ///
  /// The backend must resolve a username on the server, in the same call that checks the password, so the
  /// app never learns an email before a correct password. Wrong password and unknown email or username are
  /// the same `AuthFailure(invalidCredentials)`; `emailNotConfirmed` comes only after the right password. A
  /// backend that cannot do this must not offer username sign-in.
  Future<void> signIn({required String identifier, required String password});

  /// Creates the account and emails the 6-digit code. Returns true when the email already had an account
  /// (nothing was created and no code was sent). The screen must not tell the user: it shows the same next
  /// step either way, so sign-up never reveals which emails are registered.
  Future<bool> signUp({required String email, required String password});

  Future<void> verifySignUpCode({required String email, required String code});

  Future<void> resendSignUpCode(String email);

  /// Emails the password-reset link. An email with no account succeeds too (nothing is sent), so this
  /// never reveals which emails are registered.
  Future<void> sendPasswordReset(String email);

  Future<void> updatePassword(String newPassword);

  /// Signs out this device, or every other device when [others] is true (this one stays signed in).
  ///
  /// [others] needs backend support (Firebase's client SDK has none). An adapter that cannot do it must
  /// throw a `Failure`, never succeed silently: the reset screen tells the user the other devices stayed
  /// signed in.
  Future<void> signOut({bool others = false});

  /// Stops listening to the backend; called when the DI container is disposed.
  Future<void> dispose();
}

/// [AuthDatasource] as an adapter over Supabase Auth, with sign-in going through the `sign-in` Edge
/// Function (throttled, same answer for unknown user and wrong password).
@LazySingleton(as: AuthDatasource)
final class SupabaseAuthDatasource implements AuthDatasource {
  SupabaseAuthDatasource(this._client, this._recovery) {
    // Lives as long as the app so recovery state is right before any screen listens. gotrue replays
    // earlier events, so a link handled before this object existed is still seen.
    _events = _auth.onAuthStateChange.listen(
      _onAuthState,
      onError: _onAuthError,
    );
  }

  final SupabaseClient _client;
  final PasswordRecoveryTracker _recovery;
  late final StreamSubscription<AuthState> _events;

  GoTrueClient get _auth => _client.auth;

  void _onAuthState(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.passwordRecovery:
        unawaited(_recovery.linkOpened());
      case AuthChangeEvent.signedOut:
        unawaited(_recovery.end());
      default:
        break;
    }
  }

  // A refused link arrives as a stream error; other errors (a failed token refresh) are not about the link.
  void _onAuthError(Object error) {
    if (error is AuthException &&
        (error.code == 'access_denied' || error.statusCode == 'otp_expired')) {
      _recovery.linkRefused();
    }
  }

  @override
  bool get hasSession => _auth.currentSession != null;

  @override
  String? get currentEmail => _auth.currentUser?.email;

  @override
  Stream<SignedOutReason> get sessionEnded => _auth.onAuthStateChange
      .where(
        (state) =>
            state.event == AuthChangeEvent.signedOut &&
            state.signOutReason != null &&
            state.signOutReason != SignOutReason.userInitiated,
      )
      .map((_) => SignedOutReason.expired);

  @override
  bool get recoveryActive => hasSession && _recovery.isPending;

  @override
  Stream<RecoverySignal> get recoverySignals => _recovery.signals;

  @override
  @disposeMethod
  Future<void> dispose() => _events.cancel();

  @override
  Future<void> signIn({required String identifier, required String password}) =>
      Guard.run(() async {
        // Checked on the server (see [AuthDatasource.signIn]); it answers with tokens only.
        final response = await _client.functions.invoke(
          'sign-in',
          body: {'identifier': identifier.trim(), 'password': password},
        );
        final data = response.data;
        final refreshToken = data is Map ? data['refresh_token'] : null;
        if (refreshToken is! String || refreshToken.isEmpty) {
          throw const FormatException(
            'sign-in answered without a refresh token',
          );
        }
        await _auth.setSession(refreshToken);
        await _recovery.end();
      });

  @override
  Future<bool> signUp({required String email, required String password}) =>
      Guard.run(() async {
        try {
          final response = await _auth.signUp(
            email: email.trim(),
            password: password,
          );
          // With email confirmation on, Supabase hides an existing address as a user with no identities,
          // not as an error.
          return response.user?.identities?.isEmpty ?? false;
        } on AuthException catch (error) {
          if (error.code == 'user_already_exists' ||
              error.code == 'email_exists') {
            return true;
          }
          rethrow;
        }
      });

  @override
  Future<void> verifySignUpCode({
    required String email,
    required String code,
  }) => Guard.run(() async {
    await _auth.verifyOTP(
      type: OtpType.signup,
      email: email.trim(),
      token: code,
    );
    await _recovery.end();
  });

  @override
  Future<void> resendSignUpCode(String email) =>
      Guard.run(() => _auth.resend(type: OtpType.signup, email: email.trim()));

  @override
  Future<void> sendPasswordReset(String email) => Guard.run(() async {
    // Supabase answers success for an unknown email and sends nothing: keep it that way.
    await _auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: AppConfig.recoveryRedirectUrl,
    );
  });

  @override
  Future<void> updatePassword(String newPassword) => Guard.run(() async {
    await _auth.updateUser(UserAttributes(password: newPassword));
    await _recovery.end();
  });

  @override
  Future<void> signOut({bool others = false}) => Guard.run(() async {
    // The recovery session ends with this device's session, whether or not the server answers.
    if (!others) await _recovery.end();
    await _auth.signOut(
      scope: others ? SignOutScope.others : SignOutScope.local,
    );
  });
}
