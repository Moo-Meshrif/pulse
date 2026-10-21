import '../../../../core/utils/json_mapper.dart';

/// A row of `content_cleanup_list`: a discarded or abandoned item and its files still in storage.
class ContentCleanupModel {
  const ContentCleanupModel({this.id, this.paths});

  final String? id;

  /// Full object paths in the `post-media` bucket.
  final List<String>? paths;

  factory ContentCleanupModel.fromJson(Map<String, dynamic> json) =>
      ContentCleanupModel(
        id: JsonMapper.string(json['id']),
        paths: JsonMapper.list(json['paths'], JsonMapper.string),
      );
}
