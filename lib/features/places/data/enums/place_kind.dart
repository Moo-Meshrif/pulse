/// What a place is, as the `places` function names it. [wire] is its `kind` value.
enum PlaceKind {
  city('city'),
  town('town'),
  neighborhood('neighborhood'),
  poi('poi');

  const PlaceKind(this.wire);

  final String wire;

  static PlaceKind? fromWire(String? wire) {
    for (final kind in values) {
      if (kind.wire == wire) return kind;
    }
    return null;
  }
}
