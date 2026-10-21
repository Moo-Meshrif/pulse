import '../../../../core/utils/equatable.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../enums/mood_kind.dart';
import 'post_share_media_model.dart';
import 'post_tag_model.dart';

/// What `share_content` saves for a post: the `create_post` arguments the server posts it with, and the
/// type and size of each file it must find first.
class PostShareRequestModel extends Equatable {
  final String? caption;
  final String? location;
  final bool? commentsEnabled;
  final ContentAudience? visibility;
  final MoodKind? moodKind;
  final String? moodKey;
  final String? moodText;
  final List<PostTagModel>? tags;
  final List<PostShareMediaModel>? media;

  const PostShareRequestModel({
    this.caption,
    this.location,
    this.commentsEnabled,
    this.visibility,
    this.moodKind,
    this.moodKey,
    this.moodText,
    this.tags,
    this.media,
  });

  Map<String, dynamic> toJson() => {
    'caption': caption,
    'location': location,
    'comments_enabled': commentsEnabled,
    'visibility': visibility?.wire,
    'mood_kind': moodKind?.wire,
    'mood_key': moodKey,
    'mood_text': moodText,
    'tags': [for (final tag in tags ?? const <PostTagModel>[]) tag.toJson()],
    'media': [
      for (final item in media ?? const <PostShareMediaModel>[]) item.toJson(),
    ],
  };

  @override
  List<Object?> get props => [
    caption,
    location,
    commentsEnabled,
    visibility,
    moodKind,
    moodKey,
    moodText,
    tags,
    media,
  ];
}
