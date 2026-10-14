import '../../../../core/utils/equatable.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import 'new_post_media_entity.dart';

/// What the New post screen shares. [id] is made once per post, so a retry finds the files it already
/// uploaded.
class NewPostEntity extends Equatable {
  final String id;
  final String? caption;
  final String? location;
  final bool commentsEnabled;
  final ContentAudience visibility;
  final List<NewPostMediaEntity> media;

  const NewPostEntity({
    required this.id,
    this.caption,
    this.location,
    required this.commentsEnabled,
    required this.visibility,
    required this.media,
  });

  @override
  List<Object?> get props => [
    id,
    caption,
    location,
    commentsEnabled,
    visibility,
    media,
  ];
}
