/// The up-to-two-letter initials of [name]: the first letters of its first two words, uppercased.
String initialsOf(String? name) {
  final words = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);
  return words
      .take(2)
      .map((word) => String.fromCharCode(word.runes.first))
      .join()
      .toUpperCase();
}

/// A palette index that is the same for the same [seed] on every run (`String.hashCode` is not).
int stablePaletteIndex(String? seed, int length) {
  var hash = 0;
  for (final unit in (seed ?? '').codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash % length;
}
