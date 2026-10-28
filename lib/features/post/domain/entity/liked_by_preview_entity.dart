import '../../../../core/utils/equatable.dart';

/// The "Liked by" row of a post: the person named, how many others, and up to two avatars.
class LikedByPreviewEntity extends Equatable {
  final String firstName;

  /// People besides the one named; 0 reads "Liked by name".
  final int others;
  final List<LikedByAvatarEntity> avatars;

  /// You are the only person who liked the post: the row reads "Liked by you".
  final bool isOnlyMe;

  const LikedByPreviewEntity({
    required this.firstName,
    required this.others,
    required this.avatars,
    this.isOnlyMe = false,
  });

  /// The row with [authorId]'s avatar replaced by the given name and photo; this when they are not on it.
  LikedByPreviewEntity withAvatarOf(
    String authorId, {
    required String name,
    String? avatarUrl,
  }) {
    if (!avatars.any((avatar) => avatar.id == authorId)) return this;
    return LikedByPreviewEntity(
      firstName: firstName,
      others: others,
      isOnlyMe: isOnlyMe,
      avatars: [
        for (final avatar in avatars)
          avatar.id == authorId
              ? LikedByAvatarEntity(
                  id: authorId,
                  name: name,
                  avatarUrl: avatarUrl,
                )
              : avatar,
      ],
    );
  }

  @override
  List<Object?> get props => [firstName, others, avatars, isOnlyMe];
}

class LikedByAvatarEntity extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;

  const LikedByAvatarEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl];
}
