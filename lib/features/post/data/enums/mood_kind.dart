/// Whether a post's mood is a feeling or an activity. [wire] is the `posts.mood_kind` value.
enum MoodKind {
  feeling('feeling'),
  activity('activity');

  const MoodKind(this.wire);

  final String wire;

  static MoodKind? fromWire(String? wire) {
    for (final kind in values) {
      if (kind.wire == wire) return kind;
    }
    return null;
  }
}
