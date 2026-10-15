import '../../../../core/utils/equatable.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import 'new_post_media_entity.dart';
import 'post_media_entity.dart';
import 'post_mood_entity.dart';
import 'post_tag_entity.dart';

/// A post as the owner saved it from the edit screen: the caption, place, comments switch and audience, and the media already on the post that stay (in
/// order) and the files added from this device, which go after them.
class EditPostEntity extends Equatable {
  final String id;
  final String? caption;
  final String? location;
  final List<PostMediaEntity> kept;
  final List<NewPostMediaEntity> added;
  final bool commentsEnabled;
  final ContentAudience visibility;
  final PostMoodEntity? mood;
  final List<PostTagEntity> tags;

  const EditPostEntity({
    required this.id,
    this.caption,
    this.location,
    required this.kept,
    required this.added,
    required this.commentsEnabled,
    required this.visibility,
    this.mood,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
    id,
    caption,
    location,
    kept,
    added,
    commentsEnabled,
    visibility,
    mood,
    tags,
  ];
}
