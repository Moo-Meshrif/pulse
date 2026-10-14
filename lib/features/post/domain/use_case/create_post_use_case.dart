import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/video_thumbnail_service.dart';
import '../../data/datasource/posts_datasource.dart';
import '../../data/enums/media_type.dart';
import '../../data/model/post_media_model.dart';
import '../entity/new_post_entity.dart';
import '../entity/new_post_media_entity.dart';

/// Shares a post: uploads its files to `{uid}/{postId}/`, then inserts the post in one call. Files
/// already there from an earlier attempt are not sent again, so Retry only uploads what is missing. If
/// the insert fails the files are removed.
@injectable
class CreatePostUseCase {
  CreatePostUseCase(this._posts, this._thumbnails);

  final PostsDatasource _posts;
  final VideoThumbnailService _thumbnails;

  Future<void> call(NewPostEntity post) async {
    final folder = '${_posts.currentUserId}/${post.id}';
    final uploaded = (await _posts.listFiles(folder)).toSet();

    final media = <PostMediaModel>[];
    for (var i = 0; i < post.media.length; i++) {
      media.add(await _upload(folder, i, post.media[i], uploaded));
    }

    try {
      await _posts.createPost(
        id: post.id,
        caption: post.caption,
        location: post.location,
        commentsEnabled: post.commentsEnabled,
        visibility: post.visibility,
        media: media,
      );
    } catch (_) {
      await _removeFiles([
        for (final item in media) ...[?item.path, ?item.thumbPath],
      ]);
      rethrow;
    }
  }

  Future<PostMediaModel> _upload(
    String folder,
    int index,
    NewPostMediaEntity item,
    Set<String> uploaded,
  ) async {
    final extension = _extension(item.filePath);
    final name = '$index.$extension';
    final thumbName = '${index}_thumb.jpg';

    if (!uploaded.contains(name)) {
      await _posts.uploadFile(
        path: '$folder/$name',
        file: File(item.filePath),
        contentType: _contentType(item.isVideo, extension),
      );
    }
    if (item.isVideo && !uploaded.contains(thumbName)) {
      await _posts.uploadFile(
        path: '$folder/$thumbName',
        file: File(await _thumbnails.thumbnail(item.filePath)),
        contentType: 'image/jpeg',
      );
    }

    return PostMediaModel(
      type: item.isVideo ? MediaType.video : MediaType.image,
      path: '$folder/$name',
      thumbPath: item.isVideo ? '$folder/$thumbName' : null,
      width: item.width,
      height: item.height,
      durationMs: item.durationMs,
      blurhash: item.blurhash,
    );
  }

  /// The cleanup must not hide why the post failed.
  Future<void> _removeFiles(List<String> paths) async {
    try {
      await _posts.removeFiles(paths);
    } on Failure {
      // Leftover files are not worth a second error.
    }
  }

  String _extension(String path) {
    final dot = path.lastIndexOf('.');
    return dot < 0 ? 'jpg' : path.substring(dot + 1).toLowerCase();
  }

  String _contentType(bool isVideo, String extension) {
    if (!isVideo) return 'image/jpeg';
    return extension == 'mov' ? 'video/quicktime' : 'video/mp4';
  }
}
