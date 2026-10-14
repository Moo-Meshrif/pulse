import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../enums/content_audience.dart';
import '../model/privacy_model.dart';

/// Whether the signed-in user's account is private and which audience their next post starts with.
/// Every call throws a `Failure` on error.
abstract interface class PrivacyDatasource {
  Future<PrivacyModel> getPrivacy();

  /// Saves the audience new posts start with ("Use for future posts").
  Future<void> setDefaultAudience(ContentAudience visibility);
}

/// [PrivacyDatasource] as an adapter over Supabase: `profiles.is_private` and
/// `profiles.default_post_visibility`.
@LazySingleton(as: PrivacyDatasource)
final class SupabasePrivacyDatasource implements PrivacyDatasource {
  SupabasePrivacyDatasource(this._client);

  final SupabaseClient _client;

  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw const AuthRejectedException(AuthFailureReason.sessionExpired));

  @override
  Future<PrivacyModel> getPrivacy() => Guard.run(() async {
    final row = await _client
        .from('profiles')
        .select('is_private, default_post_visibility')
        .eq('id', _uid)
        .single();
    return PrivacyModel.fromJson(row);
  });

  @override
  Future<void> setDefaultAudience(ContentAudience visibility) => Guard.run(
    () => _client
        .from('profiles')
        .update({'default_post_visibility': visibility.wire})
        .eq('id', _uid),
  );
}
