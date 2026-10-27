import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../model/liked_by_preview_model.dart';
import '../model/post_liker_model.dart';
import '../model/post_likers_page_model.dart';

/// Who liked a post. Every call throws a `Failure` on error: a [NotFoundFailure] when the post is gone or
/// not visible.
abstract interface class PostLikesDatasource {
  /// A page of the people the signed-in user may see on [postId]'s likes, newest first, narrowed by
  /// [query] (name or username). Pass the previous page's cursor as [beforeLikedAt] and [beforeId].
  Future<PostLikersPageModel> getLikers(
    String postId, {
    String? query,
    required int limit,
    DateTime? beforeLikedAt,
    String? beforeId,
  });

  /// The "Liked by" row of [postId]; null when nobody else liked it.
  Future<LikedByPreviewModel?> getPreview(String postId);
}

/// [PostLikesDatasource] as an adapter over Supabase: `post_likers` and `liked_by_preview`.
@LazySingleton(as: PostLikesDatasource)
final class SupabasePostLikesDatasource implements PostLikesDatasource {
  SupabasePostLikesDatasource(this._client);

  /// What the functions raise for a post that is gone or not visible.
  static const _unavailable = 'P0002';

  final SupabaseClient _client;

  @override
  Future<PostLikersPageModel> getLikers(
    String postId, {
    String? query,
    required int limit,
    DateTime? beforeLikedAt,
    String? beforeId,
  }) => _call(
    'post_likers',
    {
      'p_post': postId,
      'p_query': ?query,
      'p_limit': limit,
      if (beforeLikedAt != null)
        'p_before_time': beforeLikedAt.toUtc().toIso8601String(),
      'p_before_id': ?beforeId,
    },
    (rows) {
      final likers = List<Map<String, dynamic>>.from(rows as List<dynamic>)
          .map(PostLikerModel.fromJson)
          .toList();
      // A full page may have more behind it; a short one is the end.
      final last = likers.length < limit ? null : likers.last;
      return PostLikersPageModel(
        likers: likers,
        nextLikedAt: last?.likedAt,
        nextId: last?.id,
      );
    },
  );

  @override
  Future<LikedByPreviewModel?> getPreview(String postId) =>
      _call('liked_by_preview', {'p_post': postId}, (rows) {
        final list = rows as List<dynamic>;
        return list.isEmpty
            ? null
            : LikedByPreviewModel.fromJson(
                Map<String, dynamic>.from(list.first as Map),
              );
      });

  /// Calls [function], reads the answer with [parse], and turns the "post unavailable" refusal into a failure.
  Future<T> _call<T>(
    String function,
    Map<String, dynamic> params,
    T Function(dynamic answer) parse,
  ) => Guard.run(() async {
    try {
      return parse(await _client.rpc<dynamic>(function, params: params));
    } on PostgrestException catch (error) {
      if (error.code == _unavailable) throw NotFoundException(function);
      rethrow;
    }
  });
}
