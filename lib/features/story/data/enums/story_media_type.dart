/// What a story shows. [wire] is the `stories.type` value; the same two values as a post's media, kept as
/// this feature's own enum.
enum StoryMediaType {
  image('image', contentType: 'image/jpeg', extension: 'jpg'),
  video('video', contentType: 'video/mp4', extension: 'mp4');

  const StoryMediaType(
    this.wire, {
    required this.contentType,
    required this.extension,
  });

  final String wire;

  /// The MIME type the app uploads it as.
  final String contentType;

  /// The file extension of the uploaded object.
  final String extension;

  static StoryMediaType? fromWire(String? wire) {
    for (final type in values) {
      if (type.wire == wire) return type;
    }
    return null;
  }
}
