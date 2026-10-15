import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../../../../core/utils/json_mapper.dart';
import '../model/tag_person_model.dart';
import '../model/tagged_person_model.dart';

/// Tags on posts: finding people to tag, who is tagged on a post, and removing your own tag. The
/// profile's Tagged tab (`tagged_posts`) is added with the profile feature.
abstract interface class PostTagsDatasource {
  /// People you can tag: the ones you follow when [query] is blank, otherwise those matching it.
  Future<List<TagPersonModel>> searchPeople(String? query, {int limit = 30});

  /// Everyone tagged on [postId], with how you follow each.
  Future<List<TaggedPersonModel>> getTaggedPeople(String postId);

  /// Removes your tag from [postId]; false when you were not tagged.
  Future<bool> removeMyTag(String postId);
}

/// [PostTagsDatasource] as an adapter over Supabase: `tag_search`, `post_tagged_people`, `remove_my_tag`.
@LazySingleton(as: PostTagsDatasource)
final class SupabasePostTagsDatasource implements PostTagsDatasource {
  SupabasePostTagsDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<TagPersonModel>> searchPeople(String? query, {int limit = 30}) =>
      Guard.run(() async {
        final rows = await _client.rpc<dynamic>(
          'tag_search',
          params: {'p_q': query, 'p_limit': limit},
        );
        return [
          for (final row in rows as List)
            TagPersonModel.fromJson(row as Map<String, dynamic>),
        ];
      });

  @override
  Future<List<TaggedPersonModel>> getTaggedPeople(String postId) =>
      Guard.run(() async {
        final rows = await _client.rpc<dynamic>(
          'post_tagged_people',
          params: {'p_post': postId},
        );
        return [
          for (final row in rows as List)
            TaggedPersonModel.fromJson(row as Map<String, dynamic>),
        ];
      });

  @override
  Future<bool> removeMyTag(String postId) => Guard.run(() async {
    final removed = await _client.rpc<dynamic>(
      'remove_my_tag',
      params: {'p_post': postId},
    );
    return JsonMapper.boolean(removed) ?? false;
  });
}
