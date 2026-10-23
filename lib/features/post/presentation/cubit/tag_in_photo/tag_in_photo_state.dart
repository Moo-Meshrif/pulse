import 'package:freezed_annotation/freezed_annotation.dart';

import '../../utils/tag_choice.dart';
import '../../utils/tag_photo.dart';

part 'tag_in_photo_state.freezed.dart';

@freezed
abstract class TagInPhotoState with _$TagInPhotoState {
  const TagInPhotoState._();

  const factory TagInPhotoState({
    /// The photos only: a video takes no spot.
    required List<TagPhoto> photos,

    /// The people chosen on Tag in photo's way in, with the spots set so far.
    required List<TagChoice> chosen,

    /// The photo on screen, an index into [photos].
    @Default(0) int selected,

    /// Where the person tapped, as fractions of the photo, while the pick list is open.
    double? pendingX,
    double? pendingY,
  }) = _TagInPhotoState;

  TagPhoto get photo => photos[selected];

  bool get hasPending => pendingX != null && pendingY != null;

  /// The labels on the photo on screen.
  List<TagChoice> get labels => [
    for (final choice in chosen)
      if (choice.mediaPosition == photo.position) choice,
  ];

  /// People tagged in the post but not on a photo.
  List<TagChoice> get withoutSpot => [
    for (final choice in chosen)
      if (!choice.hasSpot) choice,
  ];

  /// How many people are tagged on each photo, by the photo's position.
  Map<int, int> get countsByPosition {
    final counts = <int, int>{};
    for (final choice in chosen) {
      final position = choice.mediaPosition;
      if (position != null) counts[position] = (counts[position] ?? 0) + 1;
    }
    return counts;
  }
}
