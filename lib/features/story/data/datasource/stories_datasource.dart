import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../enums/audience_list.dart';
import '../enums/audience_tab.dart';
import '../model/audience_person_model.dart';
import '../model/new_story_model.dart';
import '../model/story_model.dart';
import '../model/story_rail_item_model.dart';
import '../model/story_viewer_model.dart';

/// Stories: the rail, a person's playlist, seen and like marks, viewers, mute, report, and the row of a
/// new story. The media files themselves go through `MediaFilesDatasource`.
abstract interface class StoriesDatasource {
  /// The signed-in user's id; no session throws an auth failure.
  String get currentUserId;

  /// You first (only with an active story), then unseen, then latest.
  Future<List<StoryRailItemModel>> getStoryRail({int limit = 30});

  /// [authorId]'s stories, oldest first, with signed media links.
  Future<List<StoryModel>> getAuthorStories(String authorId);

  /// Records that you viewed [storyId]; viewing it again changes nothing.
  Future<void> markViewed(String storyId);

  Future<void> setLiked(String storyId, {required bool liked});

  /// Who viewed your story, newest first. Pass the last row's `viewedAt` as [before] for the next page.
  Future<List<StoryViewerModel>> getViewers(
    String storyId, {
    required int limit,
    DateTime? before,
  });

  /// Deletes your story's row. Its files go through core's `RemoveMediaFilesUseCase`.
  Future<void> deleteStory(StoryModel story);

  /// Your followers for a list screen: the [tab], those matching [query], [limit] from [offset].
  Future<List<AudiencePersonModel>> getAudiencePeople(
    AudienceList list, {
    required AudienceTab tab,
    String? query,
    required int limit,
    required int offset,
  });

  /// Puts [add] on [list] and takes [remove] off it, in one call.
  Future<void> updateAudienceList(
    AudienceList list, {
    required List<String> add,
    required List<String> remove,
  });

  /// Inserts the row of a story whose files are already uploaded at [mediaPath] / [thumbPath].
  Future<void> insertStory(
    NewStoryModel story, {
    required String mediaPath,
    String? thumbPath,
  });
}

/// [StoriesDatasource] as an adapter over Supabase: `story_rail`, `author_stories`, `story_views`,
/// `set_story_like`, `story_viewers`, the `stories` table and the
/// private `post-media` bucket.
@LazySingleton(as: StoriesDatasource)
final class SupabaseStoriesDatasource implements StoriesDatasource {
  SupabaseStoriesDatasource(this._client);

  /// The bucket stories and posts share.
  static const _bucket = 'post-media';

  /// How long a signed media link works, in seconds.
  static const signedUrlSeconds = 3600;

  final SupabaseClient _client;

  @override
  String get currentUserId =>
      _client.auth.currentUser?.id ??
      (throw const AuthRejectedException(AuthFailureReason.sessionExpired));

  @override
  Future<List<StoryRailItemModel>> getStoryRail({int limit = 30}) =>
      Guard.run(() async {
        final rows = await _client.rpc<dynamic>(
          'story_rail',
          params: {'p_limit': limit},
        );
        return [
          for (final row in rows as List)
            StoryRailItemModel.fromJson(row as Map<String, dynamic>),
        ];
      });

  @override
  Future<List<StoryModel>> getAuthorStories(String authorId) =>
      Guard.run(() async {
        final rows = await _client.rpc<dynamic>(
          'author_stories',
          params: {'p_author': authorId},
        );
        final stories = [
          for (final row in rows as List)
            StoryModel.fromJson(row as Map<String, dynamic>),
        ];
        final urls = await _sign([
          for (final s in stories) ...[?s.path, ?s.thumbPath],
        ]);
        return [
          for (final s in stories)
            s.withUrls(mediaUrl: urls[s.path], thumbUrl: urls[s.thumbPath]),
        ];
      });

  /// Signed links by object path; a path that cannot be signed is left out.
  Future<Map<String, String>> _sign(List<String> paths) async {
    if (paths.isEmpty) return const {};
    final results = await _client.storage
        .from(_bucket)
        .createSignedUrlsResult(paths, signedUrlSeconds);
    return {
      for (final result in results.whereType<SignedUrlSuccess>())
        result.path: result.signedUrl,
    };
  }

  @override
  Future<void> markViewed(String storyId) => Guard.run(
    () => _client
        .from('story_views')
        .upsert(
          {'story_id': storyId},
          onConflict: 'story_id,viewer_id',
          ignoreDuplicates: true,
        ),
  );

  @override
  Future<void> setLiked(String storyId, {required bool liked}) => Guard.run(
    () => _client.rpc<dynamic>(
      'set_story_like',
      params: {'p_story': storyId, 'p_liked': liked},
    ),
  );

  @override
  Future<List<StoryViewerModel>> getViewers(
    String storyId, {
    required int limit,
    DateTime? before,
  }) => Guard.run(() async {
    final rows = await _client.rpc<dynamic>(
      'story_viewers',
      params: {
        'p_story': storyId,
        'p_limit': limit,
        if (before != null) 'p_before': before.toUtc().toIso8601String(),
      },
    );
    return [
      for (final row in rows as List)
        StoryViewerModel.fromJson(row as Map<String, dynamic>),
    ];
  });

  @override
  Future<void> deleteStory(StoryModel story) => Guard.run(() async {
    final id = story.id;
    if (id == null) throw const NotFoundException('story id');
    await _client.from('stories').delete().eq('id', id);
  });

  @override
  Future<List<AudiencePersonModel>> getAudiencePeople(
    AudienceList list, {
    required AudienceTab tab,
    String? query,
    required int limit,
    required int offset,
  }) => Guard.run(() async {
    final rows = await _client.rpc<dynamic>(
      'audience_people',
      params: {
        'p_list': list.wire,
        'p_tab': tab.wire,
        'p_query': query,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return [
      for (final row in rows as List)
        AudiencePersonModel.fromJson(row as Map<String, dynamic>),
    ];
  });

  @override
  Future<void> updateAudienceList(
    AudienceList list, {
    required List<String> add,
    required List<String> remove,
  }) => Guard.run(
    () => _client.rpc<dynamic>(
      'update_audience_list',
      params: {'p_list': list.wire, 'p_add': add, 'p_remove': remove},
    ),
  );

  @override
  Future<void> insertStory(
    NewStoryModel story, {
    required String mediaPath,
    String? thumbPath,
  }) => Guard.run(
    () => _client.from('stories').insert({
      'type': story.type.wire,
      'path': mediaPath,
      'thumb_path': thumbPath,
      'width': story.width,
      'height': story.height,
      'duration_ms': story.durationMs,
      'overlays': [for (final o in story.overlays) o.toJson()],
    }),
  );
}
