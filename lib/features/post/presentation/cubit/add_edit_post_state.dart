import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/services/media_picker_service.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/entity/post_media_entity.dart';
import '../utils/enums/new_post_notice.dart';
import '../utils/new_post_limits.dart';

part 'add_edit_post_state.freezed.dart';

@freezed
abstract class AddEditPostState with _$AddEditPostState {
  const AddEditPostState._();

  /// The screen for [post]: its caption, place, media and settings are what is being changed.
  factory AddEditPostState.editing(PostEntity post) => AddEditPostState(
    postId: post.id,
    original: post,
    caption: post.caption ?? '',
    location: post.location,
    kept: post.media,
    commentsEnabled: post.commentsEnabled,
    visibility: post.visibility,
  );

  const factory AddEditPostState({
    /// Made once, so Retry finds the files an earlier attempt uploaded; the post's own id when editing.
    required String postId,

    /// The post being edited, as it was when the screen opened; null when adding.
    PostEntity? original,
    @Default('') String caption,

    /// The media already on the post that stay; empty when adding.
    @Default([]) List<PostMediaEntity> kept,

    /// Signed links for [kept] by object path; empty until they load.
    @Default({}) Map<String, String> urls,

    /// Files picked on this device; they go after [kept].
    @Default([]) List<PickedMedia> media,

    /// A frame of each picked video, by video path; a video without one draws a plain tile.
    @Default({}) Map<String, String> posters,
    String? location,
    @Default(true) bool commentsEnabled,
    @Default(ContentAudience.public) ContentAudience visibility,

    /// The audience the account starts new posts with; a narrower choice looks different on the chip.
    @Default(ContentAudience.public) ContentAudience defaultVisibility,
    @Default(false) bool isSaving,

    /// One-shot: the post was shared or saved; the screen closes.
    @Default(false) bool isSaved,

    /// One-shot message for the screen.
    NewPostNotice? notice,
  }) = _AddEditPostState;

  bool get isEditing => original != null;

  int get mediaCount => kept.length + media.length;

  /// Something to lose when closing: written content when adding, any edit when editing.
  bool get hasContent => isEditing
      ? hasChanges
      : caption.trim().isNotEmpty || media.isNotEmpty || location != null;

  /// Edit only: anything differs from the post as it was.
  bool get hasChanges {
    final post = original;
    if (post == null) return false;
    return caption.trim() != (post.caption ?? '') ||
        location != post.location ||
        kept.length != post.media.length ||
        media.isNotEmpty ||
        commentsEnabled != post.commentsEnabled ||
        visibility != post.visibility;
  }

  /// Text or at least one photo or video, something to save when editing, and not already saving.
  bool get canSave =>
      !isSaving &&
      (!isEditing || hasChanges) &&
      (caption.trim().isNotEmpty || mediaCount > 0);

  bool get isVisibilityNarrowed => visibility.isNarrowerThan(defaultVisibility);

  bool get canAddMedia => mediaCount < NewPostLimits.maxMedia;
}
