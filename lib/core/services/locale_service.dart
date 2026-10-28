import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../error/error_reporter.dart';
import 'storage/local_storage.dart';
import 'storage/storage_keys.dart';

/// The language the person chose for the app. [locale] is null while they have not chosen one: the
/// device language applies. `App` listens to it, so a change reaches every screen at once.
abstract interface class LocaleService {
  ValueListenable<Locale?> get locale;

  /// Keeps [language] (`en` or `ar`) on this device and applies it.
  Future<void> choose(Locale language);
}

/// [LocaleService] over [LocalStorageService].
@LazySingleton(as: LocaleService)
final class StoredLocaleService implements LocaleService {
  StoredLocaleService(this._storage) : _locale = ValueNotifier(_read(_storage));

  final LocalStorageService _storage;
  final ValueNotifier<Locale?> _locale;

  /// Only the languages the app ships; anything else stored reads as "none".
  static const supported = [Locale('en'), Locale('ar')];

  static Locale? _read(LocalStorageService storage) {
    final code = storage.getValue<String>(StorageKeys.appLocale);
    for (final locale in supported) {
      if (locale.languageCode == code) return locale;
    }
    return null;
  }

  @override
  ValueListenable<Locale?> get locale => _locale;

  /// A failed write is reported, never thrown: the language applies now and just does not survive a restart.
  @override
  Future<void> choose(Locale language) async {
    _locale.value = language;
    try {
      await _storage.setValue(StorageKeys.appLocale, language.languageCode);
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }
}
