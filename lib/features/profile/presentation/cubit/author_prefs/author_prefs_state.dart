import '../../../../../core/error/failures.dart';

class AuthorPrefsState {
  const AuthorPrefsState({this.values, this.busy = false, this.failure});

  /// Close friends, post notifications, post mute, then story mute; null until loaded.
  final List<bool>? values;
  final bool busy;
  final Failure? failure;
}
