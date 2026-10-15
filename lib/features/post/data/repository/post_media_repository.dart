import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/video_thumbnail_service.dart';
import '../../domain/entity/new_post_media_entity.dart';
import '../datasource/posts_datasource.dart';
import '../enums/media_type.dart';
import '../model/post_media_model.dart';

/// Sends the files of a post to its folder of the media bucket; shared by creating and editing a post.
@lazySingleton
class PostMediaRepository {
  PostMediaRepository(this._posts, this._thumbnails);

  final PostsDatasource _posts;
  final VideoThumbnailService _thumbnails;

  /// Uploads [item] as `{folder}/{stem}.{ext}` (and `{stem}_thumb.jpg` for a video) unless a file of
  /// that name is in [uploaded] already, and describes it as the media of the post.
  Future<PostMediaModel> upload(
    String folder,
    String stem,
    NewPostMediaEntity item,
    Set<String> uploaded,
  ) async {
    final extension = _extension(item.filePath);
    final name = '$stem.$extension';
    final thumbName = '${stem}_thumb.jpg';

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
  Future<void> removeQuietly(List<String> paths) async {
    if (paths.isEmpty) return;
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
