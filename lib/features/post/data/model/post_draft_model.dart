import '../../../../core/utils/json_mapper.dart';
import 'post_draft_media_model.dart';
import 'post_draft_tag_model.dart';

/// The New post draft saved on this device: [id] is the future post's id. [visibility] and [moodKind] are
/// wire values. [isOpen]: the screen was still open when it was last saved (the app may have been killed
/// then), so the app opens it again at start. [isOnServer]: something of it may have reached the server,
/// so discarding it must tell the server.
class PostDraftModel {
  const PostDraftModel({
    this.id,
    this.caption,
    this.location,
    this.commentsEnabled,
    this.visibility,
    this.moodKind,
    this.moodKey,
    this.moodText,
    this.tags,
    this.media,
    this.isOpen = false,
    this.isOnServer = false,
  });

  /// The stored shape; a draft of another version is not read.
  static const version = 1;

  final String? id;
  final String? caption;
  final String? location;
  final bool? commentsEnabled;
  final String? visibility;
  final String? moodKind;
  final String? moodKey;
  final String? moodText;
  final List<PostDraftTagModel>? tags;
  final List<PostDraftMediaModel>? media;
  final bool isOpen;
  final bool isOnServer;

  /// Null for a draft of another [version].
  static PostDraftModel? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    if (JsonMapper.integer(json['v']) != version) return null;
    return PostDraftModel(
      id: JsonMapper.string(json['id']),
      caption: JsonMapper.string(json['caption']),
      location: JsonMapper.string(json['location']),
      commentsEnabled: JsonMapper.boolean(json['comments_enabled']),
      visibility: JsonMapper.string(json['visibility']),
      moodKind: JsonMapper.string(json['mood_kind']),
      moodKey: JsonMapper.string(json['mood_key']),
      moodText: JsonMapper.string(json['mood_text']),
      tags: JsonMapper.list(json['tags'], _tag),
      media: JsonMapper.list(json['media'], _media),
      isOpen: JsonMapper.boolean(json['open']) ?? false,
      isOnServer: JsonMapper.boolean(json['on_server']) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'v': version,
    'id': id,
    'caption': caption,
    'location': location,
    'comments_enabled': commentsEnabled,
    'visibility': visibility,
    'mood_kind': moodKind,
    'mood_key': moodKey,
    'mood_text': moodText,
    'tags': tags?.map((tag) => tag.toJson()).toList(),
    'media': media?.map((item) => item.toJson()).toList(),
    'open': isOpen,
    'on_server': isOnServer,
  };

  PostDraftModel withMedia(List<PostDraftMediaModel> media) =>
      _copy(media: media);

  PostDraftModel withState({required bool isOpen, required bool isOnServer}) =>
      _copy(isOpen: isOpen, isOnServer: isOnServer);

  PostDraftModel _copy({
    List<PostDraftMediaModel>? media,
    bool? isOpen,
    bool? isOnServer,
  }) => PostDraftModel(
    id: id,
    caption: caption,
    location: location,
    commentsEnabled: commentsEnabled,
    visibility: visibility,
    moodKind: moodKind,
    moodKey: moodKey,
    moodText: moodText,
    tags: tags,
    media: media ?? this.media,
    isOpen: isOpen ?? this.isOpen,
    isOnServer: isOnServer ?? this.isOnServer,
  );

  static PostDraftTagModel? _tag(Object? item) =>
      item is Map<String, dynamic> ? PostDraftTagModel.fromJson(item) : null;

  static PostDraftMediaModel? _media(Object? item) =>
      item is Map<String, dynamic> ? PostDraftMediaModel.fromJson(item) : null;
}
