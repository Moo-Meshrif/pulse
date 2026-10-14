import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../enums/story_media_type.dart';
import 'story_overlay_model.dart';

/// A row of `author_stories()`: one story in a person's playlist. [mediaUrl] and [thumbUrl] are signed
/// links the datasource adds; they expire, so they are never stored.
class StoryModel extends Equatable {
  final String? id;
  final StoryMediaType? type;
  final String? path;
  final String? thumbPath;
  final int? width;
  final int? height;
  final int? durationMs;
  final String? blurhash;
  final List<StoryOverlayModel>? overlays;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final bool? seenByMe;
  final bool? likedByMe;

  /// Who can see it; null from a server that does not send it yet.
  final ContentAudience? audience;

  /// Only for your own stories.
  final int? viewCount;
  final String? mediaUrl;
  final String? thumbUrl;

  const StoryModel({
    this.id,
    this.type,
    this.path,
    this.thumbPath,
    this.width,
    this.height,
    this.durationMs,
    this.blurhash,
    this.overlays,
    this.createdAt,
    this.expiresAt,
    this.seenByMe,
    this.likedByMe,
    this.audience,
    this.viewCount,
    this.mediaUrl,
    this.thumbUrl,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
    id: JsonMapper.string(json['id']),
    type: StoryMediaType.fromWire(JsonMapper.string(json['type'])),
    path: JsonMapper.string(json['path']),
    thumbPath: JsonMapper.string(json['thumb_path']),
    width: JsonMapper.integer(json['width']),
    height: JsonMapper.integer(json['height']),
    durationMs: JsonMapper.integer(json['duration_ms']),
    blurhash: JsonMapper.string(json['blurhash']),
    overlays: JsonMapper.list(
      json['overlays'],
      (item) => item is Map<String, dynamic>
          ? StoryOverlayModel.fromJson(item)
          : null,
    ),
    createdAt: JsonMapper.date(json['created_at']),
    expiresAt: JsonMapper.date(json['expires_at']),
    seenByMe: JsonMapper.boolean(json['seen_by_me']),
    likedByMe: JsonMapper.boolean(json['liked_by_me']),
    audience: ContentAudience.fromWire(json['audience']),
    viewCount: JsonMapper.integer(json['view_count']),
  );

  StoryModel withUrls({String? mediaUrl, String? thumbUrl}) =>
      copyWith(mediaUrl: mediaUrl, thumbUrl: thumbUrl);

  /// The same story with the given fields changed; a null leaves the field as it is.
  StoryModel copyWith({
    bool? seenByMe,
    bool? likedByMe,
    ContentAudience? audience,
    String? mediaUrl,
    String? thumbUrl,
  }) => StoryModel(
    id: id,
    type: type,
    path: path,
    thumbPath: thumbPath,
    width: width,
    height: height,
    durationMs: durationMs,
    blurhash: blurhash,
    overlays: overlays,
    createdAt: createdAt,
    expiresAt: expiresAt,
    seenByMe: seenByMe ?? this.seenByMe,
    likedByMe: likedByMe ?? this.likedByMe,
    audience: audience ?? this.audience,
    viewCount: viewCount,
    mediaUrl: mediaUrl ?? this.mediaUrl,
    thumbUrl: thumbUrl ?? this.thumbUrl,
  );

  @override
  List<Object?> get props => [
    id,
    type,
    path,
    thumbPath,
    width,
    height,
    durationMs,
    blurhash,
    overlays,
    createdAt,
    expiresAt,
    seenByMe,
    likedByMe,
    audience,
    viewCount,
    mediaUrl,
    thumbUrl,
  ];
}
