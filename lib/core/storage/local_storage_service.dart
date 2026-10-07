/// Key-value storage for small settings and flags. Callers depend on this type only;
/// the backend (today `SharedPrefsStorageService`) can change without touching them.
/// Generic on purpose — no keys and no feature logic; keys live in `StorageKeys`.
/// Never store tokens or personal data here (use secure storage).
///
/// Every method is abstract: a backend implements the whole contract below.
///
/// Contract: reads never throw for bad data (a missing key, a value of another type, a malformed date,
/// corrupt JSON or a [getValue] `decode` that rejects the data all read as `null`; the caller decides the
/// default); writes return `true` when the value was stored and notify [watch] only then.
abstract class LocalStorageService {
  /// Reads [key] as [T]; the data type is the type argument (`getValue<bool>('seen')`).
  ///
  /// - `String`, `bool`, `int`, `double`, `List<String>`: read as they are stored.
  /// - `DateTime`: stored as UTC ISO-8601.
  /// - Any other type (enum, model, list of models…): pass [decode], which turns the stored JSON
  ///   value into [T] — `decode: (json) => Item.fromJson(json as Map<String, dynamic>)`.
  ///
  /// A type that is neither supported nor given a [decode] is a programming error ([ArgumentError]).
  T? getValue<T>(String key, {T? Function(Object? json)? decode});

  /// Writes [value] under [key]; the type is inferred from the argument (or explicit: `setValue<bool>(…)`).
  /// Supported as in [getValue]; for any other type pass [encode], which turns [T] into a JSON-compatible
  /// value (`Map`, `List`, `String`…) — `encode: (item) => item.toJson()`.
  /// Returns `true` when the value was stored.
  Future<bool> setValue<T>(
    String key,
    T value, {
    Object? Function(T value)? encode,
  });

  bool containsKey(String key);
  Set<String> get keys;
  Future<bool> remove(String key);

  /// Removes several keys; `true` only when every removal succeeded.
  Future<bool> removeAll(Iterable<String> keys);

  Future<bool> clear();

  /// Re-reads the stored values — needed only when another isolate or process may have written them.
  Future<void> reload();

  /// Emits whenever [key] is written, removed or cleared (a `clear()` notifies every watcher).
  Stream<void> watch(String key);

  /// Releases the backend's resources; called by the DI container when it is disposed.
  Future<void> dispose();
}
