/// How the Add location search behaves (docs/specs/post/screens/s3-add-location.md > States).
abstract final class AddLocationLimits {
  /// A search starts at this many characters.
  static const minQueryLength = 2;

  /// One request per pause in typing.
  static const searchDelay = Duration(milliseconds: 300);
}
