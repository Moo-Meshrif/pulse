import 'package:injectable/injectable.dart';

import '../../data/datasource/posts_datasource.dart';
import '../entity/post_entity.dart';
import '../mapper/post_entity_mapper.dart';

/// The posts and shorts [ids] (at most 50) as the signed-in user can see them now, for a screen that
/// learned they changed. One the user can no longer see, or that is gone, is not in the answer. Throws a
/// `Failure` on error.
@injectable
class GetPostsByIdsUseCase {
  GetPostsByIdsUseCase(this._posts);

  final PostsDatasource _posts;

  Future<List<PostEntity>> call(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final posts = await _posts.getPostsByIds(ids);
    return [for (final post in posts) ?PostEntityMapper.fromModel(post)];
  }
}
