import '../../../../core/utils/equatable.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import 'new_post_media_entity.dart';
import 'post_mood_entity.dart';
import 'post_tag_entity.dart';

/// What the New post screen shares. [id] is made once per post, so a retry finds the files it already
/// uploaded. The author fields are who is sharing; with them the feed shows the post at once, without them
/// it loads again.
class NewPostEntity extends Equatable {
  final String id;
  final String? caption;
  final String? location;
  final bool commentsEnabled;
  final ContentAudience visibility;
  final List<NewPostMediaEntity> media;
  final PostMoodEntity? mood;
  final List<PostTagEntity> tags;
  final String? authorUsername;
  final String? authorFullName;
  final String? authorAvatarUrl;

  const NewPostEntity({
    required this.id,
    this.caption,
    this.location,
    required this.commentsEnabled,
    required this.visibility,
    required this.media,
    this.mood,
    this.tags = const [],
    this.authorUsername,
    this.authorFullName,
    this.authorAvatarUrl,
  });

  @override
  List<Object?> get props => [
    id,
    caption,
    location,
    commentsEnabled,
    visibility,
    media,
    mood,
    tags,
    authorUsername,
    authorFullName,
    authorAvatarUrl,
  ];
}
