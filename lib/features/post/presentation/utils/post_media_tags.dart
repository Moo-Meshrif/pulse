import '../../../../core/services/media_picker_service.dart';
import '../../domain/entity/post_media_entity.dart';
import 'tag_choice.dart';
import 'tag_photo.dart';

/// How tags follow the media of the post being written: which photos the tag pages show, and where the
/// spots go when a photo is removed.
abstract final class PostMediaTags {
  /// The post's media in the order it will have: its own ([kept]) first, then the files picked now.
  static List<TagPhoto> photos({
    required List<PostMediaEntity> kept,
    required List<PickedMedia> media,
    required Map<String, String> urls,
  }) => [
    for (final (i, item) in kept.indexed)
      TagPhoto(
        position: i,
        isVideo: item.isVideo,
        url: urls[item.isVideo ? item.thumbPath : item.path],
        aspect: item.width / item.height,
      ),
    for (final (i, item) in media.indexed)
      TagPhoto(
        position: kept.length + i,
        isVideo: item.isVideo,
        filePath: item.isVideo ? null : item.path,
        aspect: _aspectOf(item),
      ),
  ];

  /// The tags once the media at [index] is gone: its spots are off (those people stay tagged in the post)
  /// and the photos after it move up one.
  static List<TagChoice> withoutMedia(List<TagChoice> tags, int index) =>
      tags.map((tag) => _afterRemoval(tag, index)).toList();

  static List<T> without<T>(List<T> items, int index) => [
    for (final (i, item) in items.indexed)
      if (i != index) item,
  ];

  static TagChoice _afterRemoval(TagChoice tag, int removed) {
    final position = tag.mediaPosition;
    if (position == removed) return tag.withoutSpot();
    if (position == null || position < removed) return tag;
    return tag.withSpot(position - 1, tag.x ?? 0, tag.y ?? 0);
  }

  static double _aspectOf(PickedMedia item) {
    final width = item.width;
    final height = item.height;
    return width == null || height == null || height == 0 ? 1 : width / height;
  }
}
