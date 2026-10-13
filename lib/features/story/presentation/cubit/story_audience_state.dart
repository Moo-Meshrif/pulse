import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../data/enums/story_audience.dart';
import '../../data/model/audience_summary_model.dart';
import '../utils/enums/story_audience_status.dart';

part 'story_audience_state.freezed.dart';

@freezed
abstract class StoryAudienceState with _$StoryAudienceState {
  const factory StoryAudienceState({
    required StoryAudience audience,

    /// The counts under each row; loaded when the sheet opens, again after a list screen.
    @Default(AudienceSummaryModel()) AudienceSummaryModel summary,
    @Default(StoryAudienceStatus.loading) StoryAudienceStatus status,

    /// One-shot: changing the audience failed (it went back to what it was).
    Failure? failure,
  }) = _StoryAudienceState;
}
