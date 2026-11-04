import '../../data/model/liked_by_preview_model.dart';
import '../entity/liked_by_preview_entity.dart';

/// Turns a "Liked by" row from the server into a [LikedByPreviewEntity].
abstract final class LikedByPreviewMapper {
  static LikedByPreviewEntity? fromModel(LikedByPreviewModel model) {
    final fullName = model.firstFullName?.trim();
    final name = fullName != null && fullName.isNotEmpty
        ? fullName
        : model.firstUsername;
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

  static LikedByAvatarEntity? _avatar(LikedByAvatarModel model) {
    final id = model.id;
    final name = model.name;
    if (id == null || name == null) return null;
    return LikedByAvatarEntity(id: id, name: name, avatarUrl: model.avatarUrl);
  }
}
