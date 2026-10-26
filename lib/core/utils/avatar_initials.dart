/// The up-to-two-letter initials of [name] (the full name, or the username when there is none): the first
/// letters of its first two words, uppercased, ignoring a leading `@`. `?` when nothing is left.
String initialsOf(String? name) {
  final words = (name ?? '')
      .trim()
      .replaceFirst(RegExp(r'^@+'), '')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);
  final initials = words
      .take(2)
      .map((word) => String.fromCharCode(word.runes.first))
      .join()
      .toUpperCase();
  return initials.isEmpty ? '?' : initials;
}

/// A palette index that is the same for the same [seed] on every run (`String.hashCode` is not).
int stablePaletteIndex(String? seed, int length) {
  var hash = 0;
  for (final unit in (seed ?? '').codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash % length;
}
