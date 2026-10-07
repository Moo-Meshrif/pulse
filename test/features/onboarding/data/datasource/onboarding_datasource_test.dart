import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/storage/local_storage_service.dart';
import 'package:pulse/core/storage/shared_prefs_storage_service.dart';
import 'package:pulse/features/onboarding/data/datasource/onboarding_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  group('with real (in-memory) preferences', () {
    Future<OnboardingDatasource> create(Map<String, Object> values) async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues(values);
      return OnboardingDatasource(
        SharedPrefsStorageService(await SharedPreferences.getInstance()),
      );
    }

    test('onboarding is not seen on a first launch', () async {
      final datasource = await create({});
      expect(datasource.isSeen, isFalse);
    });

    test('markSeen persists the flag', () async {
      final datasource = await create({});
      await datasource.markSeen();
      expect(datasource.isSeen, isTrue);
      expect(
        (await SharedPreferences.getInstance()).getBool('onboarding_seen'),
        isTrue,
      );
    });

    test('a stored flag is read back', () async {
      final datasource = await create({'onboarding_seen': true});
      expect(datasource.isSeen, isTrue);
    });
  });

  test('a failed write is swallowed (reported), never thrown', () async {
    final storage = MockLocalStorageService();
    when(() => storage.setValue<bool>(any(), any()))
        .thenAnswer((_) async => throw Exception('disk full'));
    when(() => storage.getValue<bool>(any())).thenReturn(null);
    final datasource = OnboardingDatasource(storage);

    await expectLater(datasource.markSeen(), completes);
    expect(datasource.isSeen, isFalse);
  });
}
