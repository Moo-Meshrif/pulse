import 'package:injectable/injectable.dart';

import '../../data/datasource/post_likes_datasource.dart';
import '../entity/liked_by_preview_entity.dart';
import '../mapper/liked_by_preview_mapper.dart';

/// The "Liked by" row of [postId]; null when nobody else liked it or the row is incomplete. Throws a
/// `Failure` on error.
@injectable
class GetLikedByPreviewUseCase {
  GetLikedByPreviewUseCase(this._likes);

  final PostLikesDatasource _likes;

  Future<LikedByPreviewEntity?> call(String postId) async {
    final model = await _likes.getPreview(postId);
    return model == null ? null : LikedByPreviewMapper.fromModel(model);
  }
}
