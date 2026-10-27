import 'package:injectable/injectable.dart';

import '../../data/datasource/posts_datasource.dart';
import '../entity/post_entity.dart';
import '../mapper/post_entity_mapper.dart';

/// One post for its own page, as the signed-in user can see it now; null when it is gone or hidden from
/// them. Throws a `Failure` on error.
@injectable
class GetPostUseCase {
  GetPostUseCase(this._posts);

  final PostsDatasource _posts;

  Future<PostEntity?> call(String postId) async {
    final model = await _posts.getPost(postId);
    return model == null ? null : PostEntityMapper.fromModel(model);
  }
}
