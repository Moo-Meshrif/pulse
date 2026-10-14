import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../../../../shared/content/domain/entity/audience_summary_entity.dart';
import '../utils/enums/post_visibility_status.dart';
import '../utils/post_visibility_result.dart';

part 'post_visibility_state.freezed.dart';

@freezed
abstract class PostVisibilityState with _$PostVisibilityState {
  const factory PostVisibilityState({
    /// The choice on screen.
    required ContentAudience audience,

    /// What the post has now ("Currently: Followers"); the choice the sheet opened with.
    required ContentAudience current,
    @Default(PostVisibilityStatus.loading) PostVisibilityStatus status,
    @Default(false) bool isPrivate,
    @Default(AudienceSummaryEntity()) AudienceSummaryEntity summary,

    /// "Use for future posts" (New post only).
    @Default(false) bool saveAsDefault,
    @Default(false) bool isSaving,

    /// One-shot: confirmed; the sheet closes with this.
    PostVisibilityResult? result,

    /// One-shot: saving failed; the sheet stays open.
    Failure? failure,
  }) = _PostVisibilityState;
}
