/// Who can see a story. [wire] is the `stories.audience` value.
enum StoryAudience {
  followers('followers'),
  closeFriends('close_friends');

  const StoryAudience(this.wire);

  final String wire;

  static StoryAudience? fromWire(String? wire) {
    for (final audience in values) {
      if (audience.wire == wire) return audience;
    }
    return null;
  }
}
