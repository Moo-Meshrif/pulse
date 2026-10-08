import '../enums/auth_failure_reason.dart';

/// The requested item does not exist. [detail] is for logs, never for the UI.
class NotFoundException implements Exception {
  const NotFoundException([this.detail]);
  final String? detail;

  @override
  String toString() => 'NotFoundException: $detail';
}

/// A datasource detected an auth condition the backend did not report as an error (an unknown username,
/// a sign-up that hit an existing account, no session). `Guard` turns it into an `AuthFailure`.
class AuthRejectedException implements Exception {
  const AuthRejectedException(this.reason);
  final AuthFailureReason reason;

  @override
  String toString() => 'AuthRejectedException: $reason';
}
