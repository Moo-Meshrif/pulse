import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/suggestion_tab.dart';
import '../model/suggested_profile_model.dart';

/// Who the user follows, and who they could follow.
abstract interface class FollowsDatasource {
  Future<List<SuggestedProfileModel>> getSuggestedProfiles(
    SuggestionTab tab, {
    int limit = 20,
    int offset = 0,
  });

  Future<void> follow(String userId);

  Future<void> unfollow(String userId);

  /// Follows every id; returns how many were new.
  Future<int> followAll(List<String> userIds);
}

/// [FollowsDatasource] as an adapter over Supabase: the `follows` table and the `suggested_profiles` and
/// `follow_many` functions.
@LazySingleton(as: FollowsDatasource)
final class SupabaseFollowsDatasource implements FollowsDatasource {
  SupabaseFollowsDatasource(this._client);

  final SupabaseClient _client;

  /// The signed-in user's id; no session is `AuthFailure(sessionExpired)`.
  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw const AuthRejectedException(AuthFailureReason.sessionExpired));

  @override
  Future<List<SuggestedProfileModel>> getSuggestedProfiles(
    SuggestionTab tab, {
    int limit = 20,
    int offset = 0,
  }) => Guard.run(() async {
    final rows = await _client.rpc<List<dynamic>>(
      'suggested_profiles',
      params: {'p_tab': tab.value, 'p_limit': limit, 'p_offset': offset},
    );
    return [
      for (final row in rows)
        SuggestedProfileModel.fromJson(row as Map<String, dynamic>),
    ];
  });

  @override
  Future<void> follow(String userId) => Guard.run(
    () => _client.from('follows').upsert({
      'follower_id': _uid,
      'following_id': userId,
    }, ignoreDuplicates: true),
  );

  @override
  Future<void> unfollow(String userId) => Guard.run(
    () => _client
        .from('follows')
        .delete()
        .eq('follower_id', _uid)
        .eq('following_id', userId),
  );

  @override
  Future<int> followAll(List<String> userIds) => Guard.run(() async {
    final count = await _client.rpc<dynamic>(
      'follow_many',
      params: {'p_ids': userIds},
    );
    return JsonMapper.integer(count) ?? 0;
  });
}
