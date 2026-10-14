/// Who can see a piece of content (a post, a short or a story). [wire] is the value the backend accepts (`posts.visibility`, `stories.audience`).
enum ContentAudience {
  public('public'),
  followers('followers'),
  closeFriends('close_friends'),
  onlyMe('only_me');

  const ContentAudience(this.wire);

  final String wire;

  /// Public is the only choice that is not narrower than the default of a new post.
  bool get isNarrowerThanPublic => this != public;

  /// Reaches fewer people than [other]: the values run from widest to narrowest.
  bool isNarrowerThan(ContentAudience other) => index > other.index;

  /// Posts with these audiences show the one-time "who will see this" notice on first use.
  bool get hasFirstUseNotice => this == closeFriends || this == onlyMe;

  static ContentAudience? fromWire(Object? wire) {
    for (final visibility in values) {
      if (visibility.wire == wire) return visibility;
    }
    return null;
  }
}
