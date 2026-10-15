import '../../../../core/utils/equatable.dart';
import '../../domain/entity/post_tag_entity.dart';
import '../../domain/entity/tag_person_entity.dart';

/// A person chosen to be tagged in the post: who they are for the pages, and the spot on a photo
/// ([mediaPosition] is the photo's place in the post's media, [x] and [y] are 0..1 of the photo) when one
/// was set. Without a spot they are tagged in the post only.
class TagChoice extends Equatable {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final int? mediaPosition;
  final double? x;
  final double? y;

  const TagChoice({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.mediaPosition,
    this.x,
    this.y,
  });

  factory TagChoice.person(TagPersonEntity person) => TagChoice(
    id: person.id,
    username: person.username,
    fullName: person.fullName,
    avatarUrl: person.avatarUrl,
  );

  factory TagChoice.tag(PostTagEntity tag) => TagChoice(
    id: tag.userId,
    username: tag.username ?? '',
    fullName: tag.fullName,
    mediaPosition: tag.mediaPosition,
    x: tag.x,
    y: tag.y,
  );

  bool get hasSpot => mediaPosition != null;

  /// The name people know them by: the full name when there is one.
  String get shownName {
    final name = fullName?.trim();
    return name == null || name.isEmpty ? username : name;
  }

  TagChoice withSpot(int mediaPosition, double x, double y) => TagChoice(
    id: id,
    username: username,
    fullName: fullName,
    avatarUrl: avatarUrl,
    mediaPosition: mediaPosition,
    x: x,
    y: y,
  );

  TagChoice withoutSpot() => TagChoice(
    id: id,
    username: username,
    fullName: fullName,
    avatarUrl: avatarUrl,
  );

  PostTagEntity toTag() => PostTagEntity(
    userId: id,
    username: username,
    fullName: fullName,
    mediaPosition: mediaPosition,
    x: x,
    y: y,
  );

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    avatarUrl,
    mediaPosition,
    x,
    y,
  ];
}
