import '../../../../core/utils/equatable.dart';
import 'post_media_model.dart';

/// One file of a `PostShareRequestModel`: the post's media item with the type and size of its file and
/// thumb. A null size is not checked (not known before the upload).
class PostShareMediaModel extends Equatable {
  final PostMediaModel? media;
  final String? mimeType;
  final int? sizeBytes;
  final String? thumbMimeType;
  final int? thumbSizeBytes;

  const PostShareMediaModel({
    this.media,
    this.mimeType,
    this.sizeBytes,
    this.thumbMimeType,
    this.thumbSizeBytes,
  });

  Map<String, dynamic> toJson() => {
    ...?media?.toJson(),
    'mime': mimeType,
    'size': sizeBytes,
    'thumb_mime': thumbMimeType,
    'thumb_size': thumbSizeBytes,
  };

  @override
  List<Object?> get props => [
    media,
    mimeType,
    sizeBytes,
    thumbMimeType,
    thumbSizeBytes,
  ];
}
