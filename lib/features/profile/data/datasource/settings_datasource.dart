import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../model/settings_summary_model.dart';

/// The server side of the Settings home. Every call throws a `Failure` on error.
abstract interface class SettingsDatasource {
  /// The values beside the rows. Push counts as on while the person has no saved choice yet (the
  /// server default).
  Future<SettingsSummaryModel> getSummary();

  /// Deletes the signed-in account and everything it owns. Cannot be undone.
  Future<void> deleteAccount();
}

/// [SettingsDatasource] over `profiles`, `blocks`, `notification_prefs` and `delete_my_account`.
@LazySingleton(as: SettingsDatasource)
final class SupabaseSettingsDatasource implements SettingsDatasource {
  SupabaseSettingsDatasource(this._client);

  final SupabaseClient _client;

  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw const AuthRejectedException(AuthFailureReason.sessionExpired));

  @override
  Future<SettingsSummaryModel> getSummary() => Guard.run(() async {
    final uid = _uid;
    final (profile, blocked, prefs) = await (
      _client.from('profiles').select('is_private').eq('id', uid).single(),
      _client.from('blocks').count().eq('blocker_id', uid),
      _client
          .from('notification_prefs')
          .select('push_enabled')
          .eq('user_id', uid)
          .maybeSingle(),
    ).wait;
    return SettingsSummaryModel.fromJson({
      'is_private': profile['is_private'],
      'blocked_count': blocked,
      'push_enabled': prefs?['push_enabled'] ?? true,
    });
  });

  @override
  Future<void> deleteAccount() =>
      Guard.run(() => _client.rpc<void>('delete_my_account'));
}
