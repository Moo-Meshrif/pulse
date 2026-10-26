/// What kind of content an action is about. [wire] is the `p_kind` value of the shared RPCs.
enum ContentKind {
  post('post'),
  story('story'),
  short('short'),

  /// Only reportable: a comment has no feed, audience, mute or media of its own.
  comment('comment');

  const ContentKind(this.wire);

  final String wire;

  static ContentKind? fromWire(Object? wire) {
    for (final kind in values) {
      if (kind.wire == wire) return kind;
    }
    return null;
  }
}
