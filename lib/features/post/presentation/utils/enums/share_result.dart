/// How a try to share ended, for the sheet to act on once.
enum ShareResult {
  /// The share was handed to the sender; Home's banner shows how it goes.
  shared,

  /// Three posts are already going out; the words are kept.
  busy,
}
