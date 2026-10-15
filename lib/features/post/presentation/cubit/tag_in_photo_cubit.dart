import 'package:flutter/foundation.dart' show listEquals;
import 'package:injectable/injectable.dart';

import '../../../../core/state/base_cubit.dart';
import '../utils/tag_choice.dart';
import '../utils/tag_people_args.dart';
import 'tag_in_photo_state.dart';

/// The Tag in photo page (docs/specs/post/screens/s7-tag-in-photo.md): put each chosen person at a spot on
/// a photo, move the label, or take the spot off. One spot per person; spots are fractions of the photo.
@injectable
class TagInPhotoCubit extends BaseCubit<TagInPhotoState> {
  TagInPhotoCubit(@factoryParam TagPeopleArgs args)
    : _initial = args.chosen,
      super(
        TagInPhotoState(
          photos: [
            for (final photo in args.photos)
              if (!photo.isVideo) photo,
          ],
          chosen: args.chosen,
        ),
      );

  final List<TagChoice> _initial;

  bool get hasChanges => !listEquals(state.chosen, _initial);

  void selectPhoto(int index) {
    if (index < 0 || index >= state.photos.length) return;
    emit(state.copyWith(selected: index, pendingX: null, pendingY: null));
  }

  /// A tap on the photo: marks the spot, and the page opens the pick list. Only while somebody has no spot
  /// on this photo.
  void tapPhoto(double x, double y) =>
      emit(state.copyWith(pendingX: _clamp(x), pendingY: _clamp(y)));

  void cancelPending() => emit(state.copyWith(pendingX: null, pendingY: null));

  /// Puts [id] at the marked spot of the photo on screen; a spot they had before is gone.
  void place(String id) {
    final x = state.pendingX;
    final y = state.pendingY;
    if (x == null || y == null) return;
    emit(
      state.copyWith(
        chosen: _replace(
          id,
          (choice) => choice.withSpot(state.photo.position, x, y),
        ),
        pendingX: null,
        pendingY: null,
      ),
    );
  }

  /// A label was dragged: its spot follows, inside the photo.
  void move(String id, double x, double y) => emit(
    state.copyWith(
      chosen: _replace(
        id,
        (choice) => choice.mediaPosition == null
            ? choice
            : choice.withSpot(choice.mediaPosition!, _clamp(x), _clamp(y)),
      ),
    ),
  );

  /// The label's ×: they stay tagged in the post, without a spot.
  void removeSpot(String id) => emit(
    state.copyWith(chosen: _replace(id, (choice) => choice.withoutSpot())),
  );

  List<TagChoice> _replace(String id, TagChoice Function(TagChoice) change) => [
    for (final choice in state.chosen)
      if (choice.id == id) change(choice) else choice,
  ];

  double _clamp(double value) => value.clamp(0.0, 1.0);
}
