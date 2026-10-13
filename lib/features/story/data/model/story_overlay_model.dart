import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/story_overlay_type.dart';

/// A text or location sticker of a story (`stories.overlays` item). [x] and [y] are fractions of the
/// frame (0..1) so the sticker lands in the same place on every screen size.
class StoryOverlayModel extends Equatable {
  /// A story holds at most this many stickers (`stories_overlays_shape`).
  static const maxPerStory = 20;

  final StoryOverlayType? type;
  final String? text;
  final double? x;
  final double? y;
  final double? scale;

  /// Degrees.
  final double? rotation;

  /// `#RRGGBB`.
  final String? color;

  const StoryOverlayModel({
    this.type,
    this.text,
    this.x,
    this.y,
    this.scale,
    this.rotation,
    this.color,
  });

  factory StoryOverlayModel.fromJson(Map<String, dynamic> json) =>
      StoryOverlayModel(
        type: StoryOverlayType.fromWire(JsonMapper.string(json['type'])),
        text: JsonMapper.string(json['text']),
        x: _number(json['x']),
        y: _number(json['y']),
        scale: _number(json['scale']),
        rotation: _number(json['rotation']),
        color: JsonMapper.string(json['color']),
      );

  Map<String, dynamic> toJson() => {
    'type': type?.wire,
    'text': text,
    'x': x,
    'y': y,
    'scale': scale,
    'rotation': rotation,
    'color': color,
  };

  static double? _number(Object? value) =>
      value is num ? value.toDouble() : null;

  @override
  List<Object?> get props => [type, text, x, y, scale, rotation, color];
}
