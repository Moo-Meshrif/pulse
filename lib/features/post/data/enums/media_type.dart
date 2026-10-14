/// What a post's media item is. [wire] is the `post_media.type` value.
enum MediaType {
  image('image'),
  video('video');

  const MediaType(this.wire);

  final String wire;

  static MediaType? fromWire(String? wire) {
    for (final type in values) {
      if (type.wire == wire) return type;
    }
    return null;
  }
}
