import '../../../../core/utils/equatable.dart';
import '../../../post/domain/entity/post_entity.dart';
import '../../../post/presentation/utils/post_card_media.dart';

/// A post of the feed with its media links already signed.
class FeedPost extends Equatable {
  final PostEntity entity;
  final List<PostCardMedia> media;

  /// The media of the shared post when this is a share.
  final List<PostCardMedia> originalMedia;

  const FeedPost({
    required this.entity,
    required this.media,
    this.originalMedia = const [],
  });

  String get id => entity.id;

  @override
  List<Object?> get props => [entity, media, originalMedia];
}
