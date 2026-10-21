import 'package:flutter/foundation.dart' show listEquals, mapEquals;

import '../../../../core/services/media_picker_service.dart';
import '../../../../core/utils/uuid_v4.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../../data/enums/mood_kind.dart';
import '../../data/model/post_draft_media_model.dart';
import '../../data/model/post_draft_model.dart';
import '../../data/model/post_draft_tag_model.dart';
import '../../domain/entity/post_mood_entity.dart';
import '../cubit/add_edit_post/add_edit_post_state.dart';
import 'tag_choice.dart';

/// New post <-> the draft saved on the device.
abstract final class PostDraftMapping {
  /// The screen as the draft left it; null when there is no draft.
  static AddEditPostState? toState(PostDraftModel? draft) {
    final id = draft?.id;
    if (draft == null || id == null) return null;
    final media = draft.media ?? const <PostDraftMediaModel>[];
    final mood = _mood(draft);
    return AddEditPostState(
      postId: id,
      fromDraft: true,
      caption: draft.caption ?? '',
      location: draft.location,
      commentsEnabled: draft.commentsEnabled ?? true,
      visibility:
          ContentAudience.fromWire(draft.visibility) ?? ContentAudience.public,
      mood: mood,
      tags: [
        for (final tag in draft.tags ?? const <PostDraftTagModel>[]) ?_tag(tag),
      ],
      media: [for (final item in media) ?_picked(item)],
      posters: {
        for (final item in media)
          if (item.path != null && item.poster != null)
            item.path!: item.poster!,
      },
      mediaIds: {
        for (final item in media)
          if (item.path != null) item.path!: item.id ?? uuidV4(),
      },
    );
  }

  /// What to save; null when there is nothing in the draft (it is forgotten then).
  static PostDraftModel? toSaved(AddEditPostState state) =>
      state.hasContent ? toModel(state) : null;

  static PostDraftModel toModel(AddEditPostState state) => PostDraftModel(
    id: state.postId,
    caption: state.caption,
    location: state.location,
    commentsEnabled: state.commentsEnabled,
    visibility: state.visibility.wire,
    moodKind: state.mood?.kind.wire,
    moodKey: state.mood?.key,
    moodText: state.mood?.text,
    tags: state.tags.map(_tagModel).toList(),
    media: state.media
        .map(
          (item) => _mediaModel(
            item,
            id: state.mediaIds[item.path],
            poster: state.posters[item.path],
          ),
        )
        .toList(),
  );

  /// Something the draft keeps changed between [before] and [now].
  static bool differs(AddEditPostState before, AddEditPostState now) =>
      before.caption != now.caption ||
      before.location != now.location ||
      before.commentsEnabled != now.commentsEnabled ||
      before.visibility != now.visibility ||
      before.mood != now.mood ||
      !listEquals(before.tags, now.tags) ||
      !listEquals(before.media, now.media) ||
      !mapEquals(before.posters, now.posters) ||
      !mapEquals(before.mediaIds, now.mediaIds);

  static PostMoodEntity? _mood(PostDraftModel draft) {
    final kind = MoodKind.fromWire(draft.moodKind);
    final key = draft.moodKey;
    if (kind == null || key == null) return null;
    return PostMoodEntity(kind: kind, key: key, text: draft.moodText);
  }

  static TagChoice? _tag(PostDraftTagModel tag) {
    final id = tag.userId;
    final username = tag.username;
    if (id == null || username == null) return null;
    return TagChoice(
      id: id,
      username: username,
      fullName: tag.fullName,
      avatarUrl: tag.avatarUrl,
      mediaPosition: tag.mediaPosition,
      x: tag.x,
      y: tag.y,
    );
  }

  static PostDraftTagModel _tagModel(TagChoice tag) => PostDraftTagModel(
    userId: tag.id,
    username: tag.username,
    fullName: tag.fullName,
    avatarUrl: tag.avatarUrl,
    mediaPosition: tag.mediaPosition,
    x: tag.x,
    y: tag.y,
  );

  static PickedMedia? _picked(PostDraftMediaModel item) {
    final path = item.path;
    if (path == null) return null;
    return PickedMedia(
      path: path,
      isVideo: item.isVideo ?? false,
      durationMs: item.durationMs,
      width: item.width,
      height: item.height,
      sizeBytes: item.sizeBytes,
      blurhash: item.blurhash,
    );
  }

  static PostDraftMediaModel _mediaModel(
    PickedMedia item, {
    String? id,
    String? poster,
  }) => PostDraftMediaModel(
    id: id,
    path: item.path,
    isVideo: item.isVideo,
    width: item.width,
    height: item.height,
    durationMs: item.durationMs,
    sizeBytes: item.sizeBytes,
    blurhash: item.blurhash,
    poster: poster,
  );
}
