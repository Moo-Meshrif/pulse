import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/location_service.dart';
import 'package:pulse/features/places/data/datasource/places_datasource.dart';
import 'package:pulse/features/places/data/datasource/recent_places_datasource.dart';
import 'package:pulse/features/places/data/enums/place_kind.dart';
import 'package:pulse/features/places/data/model/place_model.dart';
import 'package:pulse/features/places/data/repository/places_repository.dart';
import 'package:pulse/features/places/domain/entity/place_entity.dart';

class _Places extends Mock implements PlacesDatasource {}

class _Recent extends Mock implements RecentPlacesDatasource {}

void main() {
  late _Places places;
  late _Recent recent;
  late PlacesRepositoryImpl repository;
  late List<PlaceModel> stored;

  const here = DevicePosition(latitude: 30.06, longitude: 31.22);

  setUpAll(() => registerFallbackValue(<PlaceModel>[]));

  setUp(() {
    places = _Places();
    recent = _Recent();
    stored = [];
    when(recent.get).thenAnswer((_) => stored);
    when(() => recent.save(any())).thenAnswer((invocation) async {
      stored = invocation.positionalArguments.first as List<PlaceModel>;
    });
    repository = PlacesRepositoryImpl(places, recent);
  });

  group('recent places', () {
    PlaceEntity place(String name, [String subtitle = 'Cairo']) =>
        PlaceEntity(name: name, subtitle: subtitle);

    test('the newest is first', () async {
      await repository.saveRecent(place('A'));
      await repository.saveRecent(place('B'));
      expect(repository.recent().map((p) => p.name), ['B', 'A']);
    });

    test('only the last 5 stay', () async {
      for (final name in ['A', 'B', 'C', 'D', 'E', 'F']) {
        await repository.saveRecent(place(name));
      }
      expect(repository.recent().map((p) => p.name), ['F', 'E', 'D', 'C', 'B']);
    });

    test('the same place moves to the front instead of repeating', () async {
      await repository.saveRecent(place('A'));
      await repository.saveRecent(place('B'));
      await repository.saveRecent(place('a'));
      expect(repository.recent().map((p) => p.name), ['a', 'B']);
    });

    test('the same name in another city is another place', () async {
      await repository.saveRecent(place('Center', 'Cairo'));
      await repository.saveRecent(place('Center', 'Alexandria'));
      expect(repository.recent(), hasLength(2));
    });

    test('a distance is not kept', () async {
      await repository.saveRecent(const PlaceEntity(name: 'A', distanceKm: 4));
      expect(repository.recent().single.distanceKm, isNull);
    });
  });

  group('finding places', () {
    test('nearby sends the position and maps the models', () async {
      when(
        () => places.getNearby(
          any(),
          any(),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer(
        (_) async => const [
          PlaceModel(
            name: ' Pure Cafe ',
            subtitle: 'Zamalek, Cairo',
            kind: PlaceKind.poi,
            distanceKm: 0.2,
          ),
          PlaceModel(subtitle: 'no name'),
          PlaceModel(name: '  '),
          PlaceModel(name: 'Park'),
        ],
      );

      final result = await repository.nearby(here, languageCode: 'ar');

      verify(() => places.getNearby(30.06, 31.22, languageCode: 'ar'))
          .called(1);
      expect(result.map((p) => p.name), ['Pure Cafe', 'Park']);
      expect(result.first.distanceKm, 0.2);
      expect(result.last.kind, PlaceKind.poi);
      expect(result.last.subtitle, '');
    });

    test('the current place is the reverse geocode of the position', () async {
      when(
        () => places.reverseGeocode(
          any(),
          any(),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer(
        (_) async => const PlaceModel(
          name: 'Zamalek',
          subtitle: 'Cairo',
          kind: PlaceKind.neighborhood,
        ),
      );

      final place = await repository.currentPlace(here, languageCode: 'en');

      expect(place?.displayName, 'Zamalek, Cairo');
      expect(place?.kind, PlaceKind.neighborhood);
    });

    test('nothing known at the position is null', () async {
      when(
        () => places.reverseGeocode(
          any(),
          any(),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async => null);
      expect(await repository.currentPlace(here, languageCode: 'en'), isNull);
    });

    test('search passes the text and the position when there is one', () async {
      when(
        () => places.searchPlaces(
          any(),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async => const [PlaceModel(name: 'Zamalek')]);

      await repository.search('zam', near: here, languageCode: 'en');
      await repository.search('zam', languageCode: 'en');

      verify(
        () => places.searchPlaces(
          'zam',
          latitude: 30.06,
          longitude: 31.22,
          languageCode: 'en',
        ),
      ).called(1);
      verify(
        () => places.searchPlaces(
          'zam',
          latitude: null,
          longitude: null,
          languageCode: 'en',
        ),
      ).called(1);
    });

    test('a failure of the function reaches the caller', () async {
      when(
        () => places.getNearby(
          any(),
          any(),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenThrow(const NetworkFailure());
      await expectLater(
        repository.nearby(here, languageCode: 'en'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('a place', () {
    test('is saved on the post as its name and first area', () {
      expect(
        const PlaceEntity(
          name: 'Pure Cafe',
          subtitle: 'Zamalek, Cairo',
        ).displayName,
        'Pure Cafe, Zamalek',
      );
      expect(const PlaceEntity(name: 'Cairo').displayName, 'Cairo');
    });

    test('never runs past 80 characters', () {
      final long = PlaceEntity(name: 'x' * 100, subtitle: 'Cairo');
      expect(long.displayName.length, 80);
    });
  });
}
