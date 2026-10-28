import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../enums/comment_audience.dart';
import '../enums/message_audience.dart';
import '../model/privacy_settings_model.dart';

/// The caller's privacy choices on `profiles`. Every call throws a `Failure` on error.
abstract interface class PrivacySettingsDatasource {
  Future<PrivacySettingsModel> get();

  Future<void> setPrivate(bool value);

  // TODO(profile-plan T9): enforce who can message when Chat exists; it is only stored for now.
  Future<void> setWhoCanMessage(MessageAudience value);

  Future<void> setWhoCanComment(CommentAudience value);

  Future<void> setShowActivity(bool value);

  Future<void> setAppearInSearch(bool value);
}

/// [PrivacySettingsDatasource] over the `profiles` columns the client may update.
@LazySingleton(as: PrivacySettingsDatasource)
final class SupabasePrivacySettingsDatasource
    implements PrivacySettingsDatasource {
  SupabasePrivacySettingsDatasource(this._client);

  final SupabaseClient _client;

  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw const AuthRejectedException(AuthFailureReason.sessionExpired));

  @override
  Future<PrivacySettingsModel> get() => Guard.run(() async {
    final row = await _client
        .from('profiles')
        .select(
          'is_private, who_can_message, who_can_comment, show_activity, appear_in_search',
        )
        .eq('id', _uid)
        .single();
    return PrivacySettingsModel.fromJson(row);
  });

  @override
  Future<void> setPrivate(bool value) => _update({'is_private': value});

  @override
  Future<void> setWhoCanMessage(MessageAudience value) =>
      _update({'who_can_message': value.wire});

  @override
  Future<void> setWhoCanComment(CommentAudience value) =>
      _update({'who_can_comment': value.wire});

  @override
  Future<void> setShowActivity(bool value) => _update({'show_activity': value});

  @override
  Future<void> setAppearInSearch(bool value) =>
      _update({'appear_in_search': value});

  Future<void> _update(Map<String, Object> values) =>
      Guard.run(() => _client.from('profiles').update(values).eq('id', _uid));
}
