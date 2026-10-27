import 'package:injectable/injectable.dart';

import '../../data/repository/post_repository.dart';
import '../entity/liked_by_preview_entity.dart';

/// The "Liked by" rows of up to 50 posts, by post id. A post that is not visible, has no likes or has an
/// incomplete row is missing from the map. Throws a `Failure` on error.
@injectable
class GetLikedByPreviewsUseCase {
  GetLikedByPreviewsUseCase(this._posts);

  final PostRepository _posts;

  Future<Map<String, LikedByPreviewEntity>> call(List<String> postIds) =>
      _posts.likedByPreviews(postIds);
}
