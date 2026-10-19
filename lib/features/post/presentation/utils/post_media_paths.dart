import '../../domain/entity/post_media_entity.dart';

extension PostMediaPaths on Iterable<PostMediaEntity> {
  /// The files to sign for these media: each file and its poster, once.
  List<String> get pathsToSign =>
      expand((item) => [item.path, ?item.thumbPath]).toSet().toList();
}
