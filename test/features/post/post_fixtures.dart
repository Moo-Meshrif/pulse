import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_media_entity.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

PostEntity testPost(
  String id, {
  String authorId = 'author',
  bool liked = false,
  int likes = 10,
  bool saved = false,
  List<PostMediaEntity> media = const [],
}) => PostEntity(
  id: id,
  authorId: authorId,
  username: 'nour.adel',
  likeCount: likes,
  commentCount: 2,
  commentsEnabled: true,
  visibility: ContentAudience.public,
  createdAt: DateTime(2026, 10, 14),
  likedByMe: liked,
  savedByMe: saved,
  media: media,
);

PostMediaEntity testMedia(String path, {String? thumbPath}) => PostMediaEntity(
  isVideo: thumbPath != null,
  path: path,
  thumbPath: thumbPath,
  width: 1000,
  height: 800,
);
