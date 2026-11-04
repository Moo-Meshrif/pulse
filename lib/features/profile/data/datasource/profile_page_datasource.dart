import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../enums/profile_grid_kind.dart';
import '../model/profile_grid_item_model.dart';
import '../model/profile_page_model.dart';

/// What a profile page reads: the header and its grids. Every call throws a `Failure` on error.
abstract interface class ProfilePageDatasource {
  /// The page of [userId], or null when nobody is there (or they blocked the caller).
  Future<ProfilePageModel?> getProfilePage(String userId);

  /// A person's posts, newest first, [limit] at a time; [before] is the last tile already shown.
  Future<List<ProfileGridItemModel>> getPosts(
    String userId, {
    ProfileGridItemModel? before,
    int limit = pageSize,
  });

  /// The posts [userId] is tagged in.
  Future<List<ProfileGridItemModel>> getTagged(
    String userId, {
    ProfileGridItemModel? before,
    int limit = pageSize,
  });

  /// The signed-in user's saved posts, last saved first.
  Future<List<ProfileGridItemModel>> getSavedPosts({
    ProfileGridItemModel? before,
    int limit = pageSize,
  });

  static const pageSize = 24;
}

/// [ProfilePageDatasource] as an adapter over the `profile_by_id`, `user_posts` and `saved_posts` functions.
@LazySingleton(as: ProfilePageDatasource)
final class SupabaseProfilePageDatasource implements ProfilePageDatasource {
  SupabaseProfilePageDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<ProfilePageModel?> getProfilePage(String userId) =>
      Guard.run(() async {
        final rows = await _client.rpc<List<dynamic>>(
          'profile_by_id',
          params: {'p_user': userId},
        );
        if (rows.isEmpty) return null;
        return ProfilePageModel.fromJson(
          Map<String, dynamic>.from(rows.first as Map),
        );
      });

  @override
  Future<List<ProfileGridItemModel>> getPosts(
    String userId, {
    ProfileGridItemModel? before,
    int limit = ProfilePageDatasource.pageSize,
  }) => _userPosts(userId, ProfileGridKind.posts, before, limit);

  @override
  Future<List<ProfileGridItemModel>> getTagged(
    String userId, {
    ProfileGridItemModel? before,
    int limit = ProfilePageDatasource.pageSize,
  }) => _userPosts(userId, ProfileGridKind.tagged, before, limit);

  Future<List<ProfileGridItemModel>> _userPosts(
    String userId,
    ProfileGridKind kind,
    ProfileGridItemModel? before,
    int limit,
  ) => _grid(
    'user_posts',
    {'p_user': userId, 'p_kind': kind.value},
    before,
    limit,
  );

  @override
  Future<List<ProfileGridItemModel>> getSavedPosts({
    ProfileGridItemModel? before,
    int limit = ProfilePageDatasource.pageSize,
  }) => _grid('saved_posts', const {}, before, limit);

  Future<List<ProfileGridItemModel>> _grid(
    String function,
    Map<String, dynamic> params,
    ProfileGridItemModel? before,
    int limit,
  ) => Guard.run(() async {
    final rows = await _client.rpc<List<dynamic>>(
      function,
      params: {
        ...params,
        'p_limit': limit,
        'p_before_time': before?.sortAt?.toIso8601String(),
        'p_before_id': before?.id,
      },
    );
    return List<Map<String, dynamic>>.from(rows)
        .map(ProfileGridItemModel.fromJson)
        .toList();
  });
}
