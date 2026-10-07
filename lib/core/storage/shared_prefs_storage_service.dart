import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_service.dart';

/// The only class that touches `SharedPreferences`. Replace it (and its binding) to change the backend.
@LazySingleton(as: LocalStorageService)
class SharedPrefsStorageService extends LocalStorageService {
  SharedPrefsStorageService(this._prefs);

  final SharedPreferences _prefs;
  final _changes = StreamController<String?>.broadcast();

  @override
  T? getValue<T>(String key, {T? Function(Object? json)? decode}) {
    if (decode != null) {
      final raw = _read<String>(key);
      if (raw == null) return null;
      try {
        return decode(jsonDecode(raw));
      } catch (_) {
        return null; // corrupt JSON, or a decode that rejects the data
      }
    }
    if (T == DateTime) {
      final raw = _read<String>(key);
      return raw == null ? null : DateTime.tryParse(raw) as T?;
    }
    return _read<T>(key);
  }

  @override
  Future<bool> setValue<T>(
    String key,
    T value, {
    Object? Function(T value)? encode,
  }) {
    if (encode != null) {
      return _write(
        key,
        () => _prefs.setString(key, jsonEncode(encode(value))),
      );
    }
    return _write(
      key,
      () => switch (value) {
        final DateTime v => _prefs.setString(key, v.toUtc().toIso8601String()),
        final String v => _prefs.setString(key, v),
        final bool v => _prefs.setBool(key, v),
        final int v => _prefs.setInt(key, v),
        final double v => _prefs.setDouble(key, v),
        final List<String> v => _prefs.setStringList(key, v),
        _ => throw ArgumentError(
          'Unsupported storage type ${value.runtimeType}',
        ),
      },
    );
  }

  @override
  bool containsKey(String key) => _prefs.containsKey(key);

  @override
  Set<String> get keys => _prefs.getKeys();

  @override
  Future<bool> remove(String key) => _write(key, () => _prefs.remove(key));

  @override
  Future<bool> removeAll(Iterable<String> keys) async {
    final results = await Future.wait([for (final key in keys) remove(key)]);
    return results.every((ok) => ok);
  }

  @override
  Future<bool> clear() => _write(null, _prefs.clear);

  @override
  Future<void> reload() => _prefs.reload();

  @override
  Stream<void> watch(String key) =>
      _changes.stream.where((changed) => changed == null || changed == key);

  @override
  @disposeMethod
  Future<void> dispose() => _changes.close();

  /// A primitive read; a value stored as another type reads as `null`, an unsupported [T] throws.
  T? _read<T>(String key) {
    final Object? value;
    try {
      value = switch (T) {
        const (String) => _prefs.getString(key),
        const (bool) => _prefs.getBool(key),
        const (int) => _prefs.getInt(key),
        const (double) => _prefs.getDouble(key),
        const (List<String>) => _prefs.getStringList(key),
        _ => throw ArgumentError('Unsupported storage type $T'),
      };
    } on ArgumentError {
      rethrow;
    } catch (_) {
      return null; // stored as another type
    }
    return value as T?;
  }

  /// [key] is `null` for a change that affects every key.
  Future<bool> _write(String? key, Future<bool> Function() write) async {
    final stored = await write();
    if (stored && !_changes.isClosed) _changes.add(key);
    return stored;
  }
}
