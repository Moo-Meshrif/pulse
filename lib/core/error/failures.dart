import '../enums/auth_failure_reason.dart';
import '../utils/equatable.dart';

/// A `Failure` says what went wrong, never how to word it; the UI translates it. `sealed`, so that
/// translation is an exhaustive `switch`. It is also an [Exception]: data code throws it and
/// `BaseCubit.run` catches it.
sealed class Failure extends Equatable implements Exception {
  const Failure();

  @override
  List<Object?> get props => const [];
}

/// The server rejected the request. [statusCode] is for logs and branching, never shown.
final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode});
  final int? statusCode;

  @override
  List<Object?> get props => [statusCode];
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

/// An auth request was refused; [reason] says why.
final class AuthFailure extends Failure {
  const AuthFailure(this.reason, {this.email, this.retryAfter});
  final AuthFailureReason reason;

  /// Only for [AuthFailureReason.emailNotConfirmed]: the account's email, so the verify step can open
  /// with it (the sign-in field may have held a username). Null for every other reason.
  final String? email;

  /// Only for [AuthFailureReason.tooManyAttempts]: how long to wait. Null for every other reason.
  final Duration? retryAfter;

  @override
  List<Object?> get props => [reason, email, retryAfter];
}

/// A uniqueness or other conflict (a username that is already taken).
final class ConflictFailure extends Failure {
  const ConflictFailure();
}

/// The device refused something the app needs (the photo library). The user can allow it in Settings.
final class PermissionFailure extends Failure {
  const PermissionFailure();
}

/// The camera could not start or capture (in use by another app, none found, init failed).
final class CameraFailure extends Failure {
  const CameraFailure();
}

/// The server refused it for good (a post it would not publish); sending it again cannot help.
final class RejectedFailure extends Failure {
  const RejectedFailure();
}

final class ParseFailure extends Failure {
  const ParseFailure();
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();
}
