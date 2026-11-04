import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../enums/notification_pref.dart';
import '../model/notification_prefs_model.dart';

/// The caller's notification switches on the server. Every call throws a `Failure` on error.
abstract interface class NotificationPrefsDatasource {
  /// The saved switches; the defaults when nothing was saved yet.
  Future<NotificationPrefsModel> get();

  /// Saves one switch.
  Future<void> set(NotificationPref pref, bool value);
}

/// [NotificationPrefsDatasource] over `notification_prefs` and `set_notification_prefs`.
@LazySingleton(as: NotificationPrefsDatasource)
final class SupabaseNotificationPrefsDatasource
    implements NotificationPrefsDatasource {
  SupabaseNotificationPrefsDatasource(this._client);

  final SupabaseClient _client;

  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw const AuthRejectedException(AuthFailureReason.sessionExpired));

  @override
  Future<NotificationPrefsModel> get() => Guard.run(() async {
    final row = await _client
        .from('notification_prefs')
        .select()
        .eq('user_id', _uid)
        .maybeSingle();
    return NotificationPrefsModel.fromJson(row);
  });

  @override
  Future<void> set(NotificationPref pref, bool value) => Guard.run(
    () => _client.rpc<void>(
      'set_notification_prefs',
      params: {
        'p': {pref.wire: value},
      },
    ),
  );
}
