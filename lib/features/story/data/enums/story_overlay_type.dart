/// A sticker drawn over a story's media.
enum StoryOverlayType {
  text('text'),
  location('location');

  const StoryOverlayType(this.wire);

  final String wire;

  static StoryOverlayType? fromWire(String? wire) {
    for (final type in values) {
      if (type.wire == wire) return type;
    }
    return null;
  }
}
