import '../../../../core/utils/equatable.dart';
import '../../data/enums/story_overlay_type.dart';
import '../../data/model/story_overlay_model.dart';

/// A sticker being placed on the edit screen: its [overlay] values (fractions of the frame) plus an id.
class StorySticker extends Equatable {
  const StorySticker({required this.id, required this.overlay});

  /// A text sticker in the middle of the upper half, white.
  factory StorySticker.text(int id, String text) => StorySticker(
    id: id,
    overlay: StoryOverlayModel(
      type: StoryOverlayType.text,
      text: text,
      x: 0.5,
      y: 0.45,
      scale: 1,
      rotation: 0,
      color: '#FFFFFF',
    ),
  );

  final int id;
  final StoryOverlayModel overlay;

  StorySticker copyWith({
    String? text,
    double? x,
    double? y,
    double? scale,
    double? rotation,
  }) => StorySticker(
    id: id,
    overlay: StoryOverlayModel(
      type: overlay.type,
      text: text ?? overlay.text,
      x: x ?? overlay.x,
      y: y ?? overlay.y,
      scale: scale ?? overlay.scale,
      rotation: rotation ?? overlay.rotation,
      color: overlay.color,
    ),
  );

  @override
  List<Object?> get props => [id, overlay];
}
