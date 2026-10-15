import '../../../../core/utils/equatable.dart';
import '../../data/model/post_tag_model.dart';

/// A person tagged on a post. [mediaPosition], [x] and [y] (0..1) are set when the tag sits on one
/// photo. The names are filled on a post that was read; a tag being sent needs only [userId], and its
/// names are for the card shown before the feed reloads.
class PostTagEntity extends Equatable {
  final String userId;
  final String? username;
  final String? fullName;
  final int? mediaPosition;
  final double? x;
  final double? y;

  const PostTagEntity({
    required this.userId,
    this.username,
    this.fullName,
    this.mediaPosition,
    this.x,
    this.y,
  });

  /// The tag as `p_tags` takes it.
  PostTagModel toModel() =>
      PostTagModel(userId: userId, mediaPosition: mediaPosition, x: x, y: y);

  @override
  List<Object?> get props => [userId, username, fullName, mediaPosition, x, y];
}
