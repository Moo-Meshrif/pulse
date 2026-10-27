import 'package:injectable/injectable.dart';

import '../../data/repository/post_repository.dart';
import '../entity/post_entity.dart';

/// The posts and shorts [ids] (at most 50) as the signed-in user can see them now, for a screen that
/// learned they changed. One the user can no longer see, or that is gone, is not in the answer. Throws a
/// `Failure` on error.
@injectable
class GetPostsByIdsUseCase {
  GetPostsByIdsUseCase(this._posts);

  final PostRepository _posts;

  Future<List<PostEntity>> call(List<String> ids) => _posts.postsByIds(ids);
}
