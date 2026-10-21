/// How a post sticker on a story is drawn (`stories.sticker.style`).
enum StoryPostStickerStyle {
  card('card'),
  media('media'),
  compact('compact');

  const StoryPostStickerStyle(this.wire);

  final String wire;

  static StoryPostStickerStyle? fromWire(String? wire) {
    for (final style in values) {
      if (style.wire == wire) return style;
    }
    return null;
  }
}
