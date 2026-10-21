import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../shared/content/data/enums/content_audience.dart';
import '../../../domain/entity/post_mood_entity.dart';
import '../../utils/enums/share_result.dart';
import '../../utils/tag_choice.dart';

part 'share_sheet_state.freezed.dart';

@freezed
abstract class ShareSheetState with _$ShareSheetState {
  const ShareSheetState._();

  const factory ShareSheetState({
    @Default('') String caption,
    @Default(ContentAudience.public) ContentAudience audience,

    /// The audience the account starts new posts with; a narrower choice looks different on the chip.
    @Default(ContentAudience.public) ContentAudience defaultAudience,
    PostMoodEntity? mood,
    String? location,
    @Default(<TagChoice>[]) List<TagChoice> tags,

    /// One-shot: how the last try ended; the sheet reacts and clears it.
    ShareResult? result,
  }) = _ShareSheetState;

  bool get isAudienceNarrowed => audience.isNarrowerThan(defaultAudience);
}
