import 'package:flutter/painting.dart';

import '../../../../core/theme/colors/app_palette.dart';
import '../../../../core/utils/equatable.dart';

/// One background the post sticker's story can have: a top to bottom gradient. [kind] is saved with the
/// sticker (`stories.sticker.bg.kind`).
class StoryPostBackground extends Equatable {
  const StoryPostBackground(this.kind, this.colors);

  /// The colors of the post's picture ([estimated] board swatches for the others).
  static const media = 'media';
  static const dark = 'dark';
  static const primary = 'primary';
  static const gradient = 'gradient';

  final String kind;
  final List<Color> colors;

  /// `#RRGGBB` of each color, as the sticker is saved.
  List<String> get hex => [for (final color in colors) _hex(color)];

  /// The six backgrounds the palette tool offers. [fromPost] are the post picture's dominant colors; when
  /// none could be read the first one is the primary gradient.
  static List<StoryPostBackground> options({
    List<Color> fromPost = const [],
  }) => [
    StoryPostBackground(media, fromPost.isEmpty ? _primary : _pair(fromPost)),
    const StoryPostBackground(dark, [AppPalette.ink, Color(0xFF2A3330)]),
    const StoryPostBackground(primary, _primary),
    const StoryPostBackground(gradient, [Color(0xFF6B8A94), Color(0xFF2F4349)]),
    const StoryPostBackground(gradient, [AppPalette.white, Color(0xFFE3E9E8)]),
    const StoryPostBackground(gradient, [Color(0xFFE58A3A), Color(0xFFB8531C)]),
  ];

  static const _primary = [AppPalette.brand, Color(0xFF1B3F3A)];

  /// Two colors from [colors]; a single one is paired with a darker shade of itself.
  static List<Color> _pair(List<Color> colors) {
    if (colors.length > 1) return colors.take(2).toList();
    final hsl = HSLColor.fromColor(colors.first);
    return [
      colors.first,
      hsl.withLightness((hsl.lightness * 0.5).clamp(0.0, 1.0)).toColor(),
    ];
  }

  static String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  List<Object?> get props => [kind, colors];
}
