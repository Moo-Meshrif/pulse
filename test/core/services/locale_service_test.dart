import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/services/locale_service.dart';
import 'package:pulse/core/services/storage/local_storage.dart';
import 'package:pulse/core/services/storage/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<LocalStorageService> _storage(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPrefsStorageService(await SharedPreferences.getInstance());
}

void main() {
  test('no saved choice means the device language', () async {
    final service = StoredLocaleService(await _storage({}));
    expect(service.locale.value, isNull);
  });

  test('a saved language is read back', () async {
    final service = StoredLocaleService(
      await _storage({StorageKeys.appLocale: 'ar'}),
    );
    expect(service.locale.value, const Locale('ar'));
  });

  test('a language the app does not have reads as none', () async {
    final service = StoredLocaleService(
      await _storage({StorageKeys.appLocale: 'fr'}),
    );
    expect(service.locale.value, isNull);
  });

  test('choose applies the language and keeps it', () async {
    final storage = await _storage({});
    final service = StoredLocaleService(storage);
    await service.choose(const Locale('ar'));
    expect(service.locale.value, const Locale('ar'));
    expect(StoredLocaleService(storage).locale.value, const Locale('ar'));
  });
}
