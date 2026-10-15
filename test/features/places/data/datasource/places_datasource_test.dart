import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/places/data/datasource/places_datasource.dart';
import 'package:pulse/features/places/data/enums/place_kind.dart';

import '../../../../helpers/backend_double.dart';

void main() {
  Future<BackendDouble> signedIn(
    Future<http.Response> Function(http.Request request) handler,
  ) async {
    final backend = BackendDouble((request) {
      if (request.url.path.endsWith('/token')) {
        return Future.value(BackendDouble.sessionResponse());
      }
      return handler(request);
    });
    await backend.signIn();
    return backend;
  }

  Map<String, dynamic> body(http.Request request) =>
      jsonDecode(request.body) as Map<String, dynamic>;

  http.Response places(List<Map<String, dynamic>> items) =>
      BackendDouble.json({'places': items});

  test(
    'search sends the trimmed text, the position and the language',
    () async {
      final backend = await signedIn(
        (_) async => places([
          {
            'name': 'Zamalek',
            'subtitle': 'Cairo',
            'kind': 'neighborhood',
            'distanceKm': 1.5,
          },
        ]),
      );
      final result = await SupabasePlacesDatasource(backend.client)
          .searchPlaces(
            '  zam ',
            latitude: 30.06,
            longitude: 31.22,
            languageCode: 'ar',
          );

      expect(body(backend.to('/functions/v1/places').single), {
        'action': 'search',
        'q': 'zam',
        'lat': 30.06,
        'lng': 31.22,
        'lang': 'ar',
      });
      expect(result.single.name, 'Zamalek');
      expect(result.single.kind, PlaceKind.neighborhood);
      expect(result.single.distanceKm, 1.5);
    },
  );

  test('search without a position sends none', () async {
    final backend = await signedIn((_) async => places([]));
    await SupabasePlacesDatasource(backend.client)
        .searchPlaces('zam', languageCode: 'en');

    final sent = body(backend.to('/functions/v1/places').single);
    expect(sent.containsKey('lat'), isFalse);
    expect(sent.containsKey('lng'), isFalse);
  });

  test('nearby sends the position and returns the places', () async {
    final backend = await signedIn(
      (_) async => places([
        {'name': 'Pure Cafe', 'subtitle': 'Zamalek, Cairo', 'kind': 'poi'},
        {'name': 'Hotel', 'kind': 'poi', 'distanceKm': 2},
      ]),
    );
    final result = await SupabasePlacesDatasource(backend.client)
        .getNearby(30.06, 31.22, languageCode: 'en');

    expect(body(backend.to('/functions/v1/places').single), {
      'action': 'nearby',
      'lat': 30.06,
      'lng': 31.22,
      'lang': 'en',
    });
    expect(result.map((p) => p.name), ['Pure Cafe', 'Hotel']);
    expect(result.last.distanceKm, 2.0);
  });

  test('reverse geocode returns the one place, or null', () async {
    var items = [
      {'name': 'Zamalek', 'subtitle': 'Cairo', 'kind': 'neighborhood'},
    ];
    final backend = await signedIn((_) async => places(items));
    final datasource = SupabasePlacesDatasource(backend.client);

    final area = await datasource.reverseGeocode(
      30.06,
      31.22,
      languageCode: 'en',
    );
    expect(area?.name, 'Zamalek');
    expect(
      body(backend.to('/functions/v1/places').single)['action'],
      'reverse',
    );

    items = [];
    expect(
      await datasource.reverseGeocode(30.06, 31.22, languageCode: 'en'),
      isNull,
    );
  });

  test(
    'an unknown kind is null and an item that is not an object is dropped',
    () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json({
          'places': [
            {'name': 'A', 'kind': 'planet'},
            'junk',
          ],
        }),
      );
      final result = await SupabasePlacesDatasource(backend.client)
          .getNearby(1, 2, languageCode: 'en');

      expect(result, hasLength(1));
      expect(result.single.kind, isNull);
    },
  );

  test('an answer without a list is a parse failure', () async {
    final backend = await signedIn((_) async => BackendDouble.json({'x': 1}));
    await expectLater(
      SupabasePlacesDatasource(backend.client)
          .getNearby(1, 2, languageCode: 'en'),
      throwsA(isA<Failure>()),
    );
  });

  test('a server error is a failure', () async {
    final backend = await signedIn(
      (_) async => http.Response(
        jsonEncode({'code': 'provider_unavailable'}),
        502,
        headers: {'content-type': 'application/json'},
      ),
    );
    await expectLater(
      SupabasePlacesDatasource(backend.client)
          .searchPlaces('zam', languageCode: 'en'),
      throwsA(isA<Failure>()),
    );
  });
}
