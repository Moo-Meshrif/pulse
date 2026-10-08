/// Value equality from a list of fields. Pure Dart: no package.
abstract class Equatable {
  const Equatable();

  /// Every field that makes two instances equal.
  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Equatable &&
          runtimeType == other.runtimeType &&
          _equals(props, other.props);

  @override
  int get hashCode => Object.hash(runtimeType, _hash(props));

  @override
  String toString() => '$runtimeType(${props.join(', ')})';
}

bool _equals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is List && b is List) return _all(a, b);
  if (a is Set && b is Set) return a.length == b.length && a.every(b.contains);
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.every((k) => b.containsKey(k) && _equals(a[k], b[k]));
  }
  return a == b;
}

bool _all(List a, List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!_equals(a[i], b[i])) return false;
  }
  return true;
}

int _hash(Object? value) => switch (value) {
  List() => Object.hashAll(value.map(_hash)),
  Set() => Object.hashAllUnordered(value.map(_hash)),
  Map() => Object.hashAllUnordered(
    value.entries.map((e) => Object.hash(_hash(e.key), _hash(e.value))),
  ),
  _ => value.hashCode,
};
