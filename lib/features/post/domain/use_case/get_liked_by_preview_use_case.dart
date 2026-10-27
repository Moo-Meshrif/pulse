import 'package:injectable/injectable.dart';

import '../../data/datasource/post_likes_datasource.dart';
import '../../data/model/liked_by_preview_model.dart';
import '../entity/liked_by_preview_entity.dart';

/// The "Liked by" row of [postId]; null when nobody else liked it or the row is incomplete. Throws a
/// `Failure` on error.
@injectable
class GetLikedByPreviewUseCase {
  GetLikedByPreviewUseCase(this._likes);

  final PostLikesDatasource _likes;

  Future<LikedByPreviewEntity?> call(String postId) async {
    final model = await _likes.getPreview(postId);
    if (model == null) return null;
    // The username is what the row names (the board: "Liked by salma.ash").
    final name = model.firstUsername;
    if (name == null) return null;
    return LikedByPreviewEntity(
      firstName: name,
      others: model.others ?? 0,
      isOnlyMe: model.onlyMe ?? false,
      avatars: [
        for (final avatar in model.avatars ?? const <LikedByAvatarModel>[])
          ?_avatar(avatar),
      ],
    );
  }

  LikedByAvatarEntity? _avatar(LikedByAvatarModel model) {
    final id = model.id;
    final name = model.name;
    if (id == null || name == null) return null;
    return LikedByAvatarEntity(id: id, name: name, avatarUrl: model.avatarUrl);
  }
}
