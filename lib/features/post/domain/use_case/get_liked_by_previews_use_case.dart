import 'package:injectable/injectable.dart';

import '../../data/datasource/post_likes_datasource.dart';
import '../entity/liked_by_preview_entity.dart';
import '../mapper/liked_by_preview_mapper.dart';

/// The "Liked by" rows of up to 50 posts, by post id. A post that is not visible, has no likes or has an
/// incomplete row is missing from the map. Throws a `Failure` on error.
@injectable
class GetLikedByPreviewsUseCase {
  GetLikedByPreviewsUseCase(this._likes);

  final PostLikesDatasource _likes;

  Future<Map<String, LikedByPreviewEntity>> call(List<String> postIds) async {
    final models = await _likes.getPreviews(postIds);
    final previews = <String, LikedByPreviewEntity>{};
    for (final entry in models.entries) {
      final preview = LikedByPreviewMapper.fromModel(entry.value);
      if (preview != null) previews[entry.key] = preview;
    }
    return previews;
  }
}
