import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../shared/content/data/enums/content_audience.dart';
import '../../../../../shared/content/domain/entity/audience_summary_entity.dart';
import '../../utils/enums/story_audience_status.dart';

part 'story_audience_state.freezed.dart';

@freezed
abstract class StoryAudienceState with _$StoryAudienceState {
  const factory StoryAudienceState({
    required ContentAudience audience,

    /// The counts under each row; loaded when the sheet opens, again after a list screen.
    @Default(AudienceSummaryEntity()) AudienceSummaryEntity summary,
    @Default(StoryAudienceStatus.loading) StoryAudienceStatus status,

    /// One-shot: changing the audience failed (it went back to what it was).
    Failure? failure,
  }) = _StoryAudienceState;
}
