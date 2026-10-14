/// A place name cut around the part the person typed, so the part can be drawn bold.
class MatchHighlight {
  final String before;
  final String match;
  final String after;

  const MatchHighlight(this.before, this.match, this.after);

  /// The first case-insensitive occurrence of [query] in [name]; no match leaves it all in [before].
  factory MatchHighlight.of(String name, String query) {
    final needle = query.trim().toLowerCase();
    final lower = name.toLowerCase();
    // Lower-casing can change a name's length in some scripts: the offsets would no longer fit.
    final at = needle.isEmpty || lower.length != name.length
        ? -1
        : lower.indexOf(needle);
    if (at < 0) return MatchHighlight(name, '', '');
    final end = at + needle.length;
    return MatchHighlight(
      name.substring(0, at),
      name.substring(at, end),
      name.substring(end),
    );
  }

  bool get hasMatch => match.isNotEmpty;
}
