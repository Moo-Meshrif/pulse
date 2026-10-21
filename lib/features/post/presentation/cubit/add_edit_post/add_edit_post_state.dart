import 'package:flutter/foundation.dart' show listEquals;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/services/media_picker_service.dart';
import '../../../../../shared/content/data/enums/content_audience.dart';
import '../../../domain/entity/post_entity.dart';
import '../../../domain/entity/post_media_entity.dart';
import '../../../domain/entity/post_mood_entity.dart';
import '../../utils/enums/new_post_notice.dart';
import '../../utils/new_post_limits.dart';
import '../../utils/tag_choice.dart';

part 'add_edit_post_state.freezed.dart';

@freezed
abstract class AddEditPostState with _$AddEditPostState {
  const AddEditPostState._();

  /// The screen for [post]: its caption, place, media and settings are what is being changed.
  factory AddEditPostState.editing(
    PostEntity post,
    Map<String, String>? signedUrls,
  ) => AddEditPostState(
    postId: post.id,
    original: post,
    urls: signedUrls ?? {},
    caption: post.caption ?? '',
    location: post.location,
    kept: post.media,
    commentsEnabled: post.commentsEnabled,
    visibility: post.visibility,
    tags: [for (final tag in post.tags) TagChoice.tag(tag)],
    mood: post.mood,
  );

  const factory AddEditPostState({
    /// Made once, so Retry finds the files an earlier attempt uploaded; the post's own id when editing.
    required String postId,

    /// The post being edited, as it was when the screen opened; null when adding.
    PostEntity? original,

    /// Adding: the screen opened with the saved draft, so its audience is kept.
    @Default(false) bool fromDraft,
    @Default('') String caption,

    /// The media already on the post that stay; empty when adding.
    @Default([]) List<PostMediaEntity> kept,

    /// Signed links for [kept] by object path; empty until they load.
    @Default({}) Map<String, String> urls,

    /// Files picked on this device; they go after [kept].
    @Default([]) List<PickedMedia> media,

    /// A frame of each picked video, by video path; a video without one draws a plain tile.
    @Default({}) Map<String, String> posters,

    /// Adding: the name of each picked file on the server, by path; it never changes.
    @Default({}) Map<String, String> mediaIds,

    /// Adding: the picked files whose upload failed, by path; a tap tries again.
    @Default({}) Set<String> failedUploads,
    String? location,
    @Default(true) bool commentsEnabled,
    @Default(ContentAudience.public) ContentAudience visibility,

    /// The people tagged, with the spot each has on a photo when one was set.
    @Default(<TagChoice>[]) List<TagChoice> tags,

    /// How the author feels, shown in the headline.
    PostMoodEntity? mood,

    /// The audience the account starts new posts with; a narrower choice looks different on the chip.
    @Default(ContentAudience.public) ContentAudience defaultVisibility,

    /// One-shot: the post was handed over to be sent; the screen closes.
    @Default(false) bool isSaved,

    /// One-shot message for the screen.
    NewPostNotice? notice,
  }) = _AddEditPostState;

  bool get isEditing => original != null;

  int get mediaCount => kept.length + media.length;

  /// Something to lose when closing: written content when adding, any edit when editing.
  bool get hasContent => isEditing
      ? hasChanges
      : caption.trim().isNotEmpty ||
            media.isNotEmpty ||
            location != null ||
            tags.isNotEmpty ||
            mood != null;

  /// Edit only: anything differs from the post as it was.
  bool get hasChanges {
    final post = original;
    if (post == null) return false;
    return caption.trim() != (post.caption ?? '') ||
        location != post.location ||
        kept.length != post.media.length ||
        media.isNotEmpty ||
        commentsEnabled != post.commentsEnabled ||
        visibility != post.visibility ||
        mood != post.mood ||
        !listEquals(tags, [for (final tag in post.tags) TagChoice.tag(tag)]);
  }

  /// Text or at least one photo or video, and something to save when editing.
  bool get canSave =>
      (!isEditing || hasChanges) &&
      (caption.trim().isNotEmpty || mediaCount > 0);

  bool get isVisibilityNarrowed => visibility.isNarrowerThan(defaultVisibility);

  bool get canAddMedia => mediaCount < NewPostLimits.maxMedia;
}
