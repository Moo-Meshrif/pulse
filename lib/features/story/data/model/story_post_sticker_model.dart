import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/story_post_sticker_style.dart';

/// The post sticker of a story (`stories.sticker`): how it is drawn and where it sits. [x] and [y] are
/// fractions of the screen (0..1), [rotation] is in degrees. The post itself is a [StorySharedPostModel].
class StoryPostStickerModel extends Equatable {
  final StoryPostStickerStyle? style;
  final double? x;
  final double? y;
  final double? scale;
  final double? rotation;

  /// What the background is made of (`gradient`, ...) and its colors, `#RRGGBB`.
  final String? backgroundKind;
  final List<String>? backgroundColors;

  const StoryPostStickerModel({
    this.style,
    this.x,
    this.y,
    this.scale,
    this.rotation,
    this.backgroundKind,
    this.backgroundColors,
  });

  factory StoryPostStickerModel.fromJson(Map<String, dynamic> json) {
    final background = json['bg'];
    final bg = background is Map<String, dynamic> ? background : null;
    return StoryPostStickerModel(
      style: StoryPostStickerStyle.fromWire(JsonMapper.string(json['style'])),
      x: _number(json['x']),
      y: _number(json['y']),
      scale: _number(json['scale']),
      rotation: _number(json['rotation']),
      backgroundKind: JsonMapper.string(bg?['kind']),
      backgroundColors: JsonMapper.list(bg?['colors'], JsonMapper.string),
    );
  }

  /// The sticker as `share_content` takes it.
  Map<String, dynamic> toJson() => {
    'style': style?.wire,
    'x': x,
    'y': y,
    'scale': scale,
    'rotation': rotation,
    'bg': {'kind': backgroundKind, 'colors': backgroundColors},
  };

  static double? _number(Object? value) =>
      value is num ? value.toDouble() : null;

  @override
  List<Object?> get props => [
    style,
    x,
    y,
    scale,
    rotation,
    backgroundKind,
    backgroundColors,
  ];
}
