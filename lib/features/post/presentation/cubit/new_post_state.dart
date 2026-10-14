import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/services/media_picker_service.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../utils/enums/new_post_notice.dart';
import '../utils/new_post_limits.dart';

part 'new_post_state.freezed.dart';

@freezed
abstract class NewPostState with _$NewPostState {
  const NewPostState._();

  const factory NewPostState({
    /// Made once, so Retry finds the files an earlier attempt uploaded.
    required String postId,
    @Default('') String caption,
    @Default([]) List<PickedMedia> media,

    /// A frame of each picked video, by video path; a video without one draws a plain tile.
    @Default({}) Map<String, String> posters,
    String? location,
    @Default(true) bool commentsEnabled,
    @Default(ContentAudience.public) ContentAudience visibility,

    /// The audience the account starts new posts with; a narrower choice looks different on the chip.
    @Default(ContentAudience.public) ContentAudience defaultVisibility,
    @Default(false) bool isSharing,

    /// One-shot: the post was shared; the screen closes.
    @Default(false) bool isShared,

    /// One-shot message for the screen.
    NewPostNotice? notice,
  }) = _NewPostState;

  bool get hasContent =>
      caption.trim().isNotEmpty || media.isNotEmpty || location != null;

  /// Text or at least one photo or video, and not already sending.
  bool get canShare =>
      !isSharing && (caption.trim().isNotEmpty || media.isNotEmpty);

  bool get isVisibilityNarrowed => visibility.isNarrowerThan(defaultVisibility);

  bool get canAddMedia => media.length < NewPostLimits.maxMedia;
}
