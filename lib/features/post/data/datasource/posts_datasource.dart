import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../enums/mood_kind.dart';
import '../model/feed_page_model.dart';
import '../model/post_media_model.dart';
import '../model/post_model.dart';
import '../model/post_tag_model.dart';

/// Posts: the home feed, signed links to their media, and editing one (a new post is shared through
/// `PendingContentDatasource`). What people do to a post (like, save, hide, report, delete...) is the core
/// `PostActionsDatasource`.
abstract interface class PostsDatasource {
  /// The signed-in user's id; no session throws an auth failure.
  String get currentUserId;

  /// A page of the feed, newest first. Pass the previous page's cursor as [beforeCreated] and
  /// [beforeId] for the next one.
  Future<FeedPageModel> getHomeFeed({
    required int limit,
    DateTime? beforeCreated,
    String? beforeId,
  });

  /// Signed links by object path; a path that cannot be signed is left out.
  Future<Map<String, String>> signMediaUrls(List<String> paths);

  /// Shares the Public post [postId] to the signed-in user's feed and returns the new post's id. A share
  /// of a share is made of its original. Throws a [NotFoundFailure] when the post is gone or can't be
  /// shared, and a [ServerFailure] for a caption over 2000 characters. A share has no photo, so a tag
  /// carries no spot.
  Future<String> shareToFeed({
    required String postId,
    String? caption,
    ContentAudience? audience,
    MoodKind? moodKind,
    String? moodKey,
    String? moodText,
    String? location,
    List<PostTagModel> tags = const [],
  });

  /// Replaces the caption, place, media list, mood and tags of the signed-in user's post [id]; the
  /// [media] files are already uploaded.
  Future<void> updatePost({
    required String id,
    String? caption,
    String? location,
    required List<PostMediaModel> media,
    MoodKind? moodKind,
    String? moodKey,
    String? moodText,
    List<PostTagModel> tags = const [],
  });
}

/// [PostsDatasource] as an adapter over Supabase: `home_feed`, `update_post` and the private
/// `post-media` bucket.
@LazySingleton(as: PostsDatasource)
final class SupabasePostsDatasource implements PostsDatasource {
  SupabasePostsDatasource(this._client);

  static const _bucket = 'post-media';

  /// The code `share_to_feed` raises as `post_unavailable`.
  static const _postUnavailable = 'P0002';

  /// How long a signed media link works, in seconds.
  static const _signedUrlSeconds = 3600;

  final SupabaseClient _client;

  @override
  String get currentUserId =>
      _client.auth.currentUser?.id ??
      (throw const AuthRejectedException(AuthFailureReason.sessionExpired));

  @override
  Future<FeedPageModel> getHomeFeed({
    required int limit,
    DateTime? beforeCreated,
    String? beforeId,
  }) => Guard.run(() async {
    final rows = await _client.rpc<List<dynamic>>(
      'home_feed',
      params: {
        'p_limit': limit,
        if (beforeCreated != null)
          'p_before_created': beforeCreated.toUtc().toIso8601String(),
        'p_before_id': ?beforeId,
      },
    );
    final posts = List<Map<String, dynamic>>.from(rows)
        .map(PostModel.fromJson)
        .toList();
    // A full page may have more behind it; a short one is the end.
    final last = posts.length < limit ? null : posts.last;
    return FeedPageModel(
      posts: posts,
      nextBeforeCreated: last?.createdAt,
      nextBeforeId: last?.id,
    );
  });

  @override
  Future<Map<String, String>> signMediaUrls(List<String> paths) =>
      Guard.run(() async {
        if (paths.isEmpty) return const {};
        final results = await _client.storage
            .from(_bucket)
            .createSignedUrlsResult(paths, _signedUrlSeconds);
        return {
          for (final result in results.whereType<SignedUrlSuccess>())
            result.path: result.signedUrl,
        };
      });

  @override
  Future<String> shareToFeed({
    required String postId,
    String? caption,
    ContentAudience? audience,
    MoodKind? moodKind,
    String? moodKey,
    String? moodText,
    String? location,
    List<PostTagModel> tags = const [],
  }) => Guard.run(() async {
    try {
      final id = await _client.rpc<String>(
        'share_to_feed',
        params: {
          'p_post': postId,
          'p_caption': caption,
          'p_visibility': audience?.wire,
          'p_mood_kind': moodKind?.wire,
          'p_mood_key': moodKey,
          'p_mood_text': moodText,
          'p_location': location,
          'p_tags': tags.map((tag) => tag.toJson()).toList(),
        },
      );
      return id;
    } on PostgrestException catch (error) {
      if (error.code == _postUnavailable) throw const NotFoundException('post');
      rethrow;
    }
  });

  @override
  Future<void> updatePost({
    required String id,
    String? caption,
    String? location,
    required List<PostMediaModel> media,
    MoodKind? moodKind,
    String? moodKey,
    String? moodText,
    List<PostTagModel> tags = const [],
  }) => Guard.run(
    () => _client.rpc<dynamic>(
      'update_post',
      params: {
        'p_id': id,
        'p_caption': caption,
        'p_location': location,
        'p_media': media.map((item) => item.toJson()).toList(),
        'p_mood_kind': moodKind?.wire,
        'p_mood_key': moodKey,
        'p_mood_text': moodText,
        'p_tags': tags.map((tag) => tag.toJson()).toList(),
      },
    ),
  );
}
