import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/services/local_storage_service.dart';
import 'package:pulse/core/services/storage_keys.dart';
import 'package:pulse/shared/places/data/datasource/recent_places_datasource.dart';
import 'package:pulse/shared/places/data/enums/place_kind.dart';
import 'package:pulse/shared/places/data/model/place_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<RecentPlacesDatasource> build([
    Map<String, Object> initial = const {},
  ]) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues(initial);
    return RecentPlacesDatasource(
      SharedPrefsStorageService(await SharedPreferences.getInstance()),
    );
  }

  test('nothing is saved at first', () async {
    expect((await build()).get(), isEmpty);
  });

  test('places come back in order, without their distance', () async {
    final recent = await build();
    await recent.save(const [
      PlaceModel(
        name: 'Zamalek',
        subtitle: 'Cairo',
        kind: PlaceKind.neighborhood,
        distanceKm: 3,
      ),
      PlaceModel(name: 'Pure Cafe', subtitle: 'Zamalek', kind: PlaceKind.poi),
    ]);

    final saved = recent.get();
    expect(saved.map((p) => p.name), ['Zamalek', 'Pure Cafe']);
    expect(saved.first.kind, PlaceKind.neighborhood);
    expect(saved.first.distanceKm, isNull);
  });

  test('a corrupt entry is skipped, the others stay', () async {
    final recent = await build({
      StorageKeys.recentPlaces: [
        'not json',
        '{"name":"Zamalek","subtitle":"Cairo","kind":"poi"}',
        '[1]',
      ],
    });
    expect(recent.get().map((p) => p.name), ['Zamalek']);
  });
}
