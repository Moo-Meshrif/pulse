import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/follow_status.dart';
import '../enums/suggestion_tab.dart';
import '../model/follow_request_model.dart';
import '../model/suggested_profile_model.dart';

/// Who the user follows, who they could follow, and the follow requests waiting for them.
abstract interface class FollowsDatasource {
  Future<List<SuggestedProfileModel>> getSuggestedProfiles(
    SuggestionTab tab, {
    int limit = 20,
    int offset = 0,
  });

  /// Follows [userId]; the backend decides the result: [FollowStatus.accepted] for a public profile,
  /// [FollowStatus.pending] for a private one.
  Future<FollowStatus> follow(String userId);

  /// Unfollows [userId], or cancels a pending request to them.
  Future<void> unfollow(String userId);

  /// Follows every id; returns how many were new.
  Future<int> followAll(List<String> userIds);

  /// The requests waiting for the signed-in user, newest first.
  Future<List<FollowRequestModel>> getRequests({
    int limit = 20,
    int offset = 0,
  });

  /// How many requests are waiting for the signed-in user.
  Future<int> getRequestCount();

  Future<void> acceptRequest(String followerId);

  /// Accepts every waiting request.
  Future<void> acceptAllRequests();

  Future<void> declineRequest(String followerId);
}

/// [FollowsDatasource] as an adapter over Supabase: the `follows` table and the `suggested_profiles`,
/// `follow_many` and `follow_requests` functions.
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
  Future<FollowStatus> follow(String userId) => Guard.run(() async {
    final uid = _uid;
    await _client.from('follows').upsert({
      'follower_id': uid,
      'following_id': userId,
    }, ignoreDuplicates: true);
    // The trigger sets the status; read it back (also covers a follow that already existed).
    final row = await _client
        .from('follows')
        .select('status')
        .eq('follower_id', uid)
        .eq('following_id', userId)
        .maybeSingle();
    return FollowStatus.fromJson(row?['status']);
  });

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

  @override
  Future<List<FollowRequestModel>> getRequests({
    int limit = 20,
    int offset = 0,
  }) => Guard.run(() async {
    final rows = await _client.rpc<List<dynamic>>(
      'follow_requests',
      params: {'p_limit': limit, 'p_offset': offset},
    );
    return [
      for (final row in rows)
        FollowRequestModel.fromJson(row as Map<String, dynamic>),
    ];
  });

  @override
  Future<int> getRequestCount() => Guard.run(() async {
    final response = await _client
        .from('follows')
        .select('follower_id')
        .eq('following_id', _uid)
        .eq('status', FollowStatus.pending.value)
        .count(CountOption.exact);
    return response.count;
  });

  @override
  Future<void> acceptRequest(String followerId) => Guard.run(
    () => _client
        .from('follows')
        .update({'status': FollowStatus.accepted.value})
        .eq('following_id', _uid)
        .eq('follower_id', followerId)
        .eq('status', FollowStatus.pending.value),
  );

  @override
  Future<void> acceptAllRequests() => Guard.run(
    () => _client
        .from('follows')
        .update({'status': FollowStatus.accepted.value})
        .eq('following_id', _uid)
        .eq('status', FollowStatus.pending.value),
  );

  @override
  Future<void> declineRequest(String followerId) => Guard.run(
    () => _client
        .from('follows')
        .delete()
        .eq('following_id', _uid)
        .eq('follower_id', followerId)
        .eq('status', FollowStatus.pending.value),
  );
}
