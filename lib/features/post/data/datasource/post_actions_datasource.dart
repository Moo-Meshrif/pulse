import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../../../../core/utils/json_mapper.dart';

/// What a person does to a post from any list that shows it: like, save, hide, turn comments on or off,
/// delete. Report, audience and mute are the shared `ContentActionsDatasource`. Post's own: other features reach it through the use cases in `domain/use_case`.
abstract interface class PostActionsDatasource {
  /// Likes or unlikes [postId]; returns the post's like count afterwards.
  Future<int> setLike(String postId, {required bool liked});

  /// Saves or unsaves [postId]; returns where the save stands afterwards.
  Future<bool> setSave(String postId, {required bool saved});

  /// Hides [postId] from your feed ([hidden]) or brings it back (Undo).
  Future<void> hidePost(String postId, {required bool hidden});

  /// Turns comments on or off for your post.
  Future<void> setCommentsEnabled(String postId, {required bool enabled});

  /// Deletes your post's row. Its files go through `PostRepository.deletePost`.
  Future<void> deletePost(String postId);
}

/// [PostActionsDatasource] as an adapter over Supabase: `set_post_like`, `set_post_save`, `hide_post`,
/// the `posts` table.
@LazySingleton(as: PostActionsDatasource)
final class SupabasePostActionsDatasource implements PostActionsDatasource {
  SupabasePostActionsDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<int> setLike(String postId, {required bool liked}) =>
      Guard.run(() async {
        final count = await _client.rpc<dynamic>(
          'set_post_like',
          params: {'p_post': postId, 'p_liked': liked},
        );
        return JsonMapper.integer(count) ?? 0;
      });

  @override
  Future<bool> setSave(String postId, {required bool saved}) =>
      Guard.run(() async {
        final result = await _client.rpc<dynamic>(
          'set_post_save',
          params: {'p_post': postId, 'p_saved': saved},
        );
        return JsonMapper.boolean(result) ?? saved;
      });

  @override
  Future<void> hidePost(String postId, {required bool hidden}) => Guard.run(
    () => _client.rpc<dynamic>(
      'hide_post',
      params: {'p_post': postId, 'p_hidden': hidden},
    ),
  );

  @override
  Future<void> setCommentsEnabled(String postId, {required bool enabled}) =>
      Guard.run(
        () => _client
            .from('posts')
            .update({'comments_enabled': enabled})
            .eq('id', postId),
      );

  @override
  Future<void> deletePost(String postId) =>
      Guard.run(() => _client.from('posts').delete().eq('id', postId));
}
