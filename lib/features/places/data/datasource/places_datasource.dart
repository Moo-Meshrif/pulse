import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../../../../core/utils/json_mapper.dart';
import '../model/place_model.dart';

/// Places for the Add location screen, from the `places` Edge Function (the provider and its limits stay
/// on the server). [languageCode] is the app's language: the function words the names for it.
abstract interface class PlacesDatasource {
  /// Places matching [query], nearest first when a position is given.
  Future<List<PlaceModel>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
    required String languageCode,
  });

  /// Up to 10 places within about 5 km.
  Future<List<PlaceModel>> getNearby(
    double latitude,
    double longitude, {
    required String languageCode,
  });

  /// The area and city the position is in; null when nothing is known there.
  Future<PlaceModel?> reverseGeocode(
    double latitude,
    double longitude, {
    required String languageCode,
  });
}

/// [PlacesDatasource] over Supabase's `places` function. The signed-in session is sent with the call.
@LazySingleton(as: PlacesDatasource)
class SupabasePlacesDatasource implements PlacesDatasource {
  SupabasePlacesDatasource(this._client);

  static const _function = 'places';

  final SupabaseClient _client;

  @override
  Future<List<PlaceModel>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
    required String languageCode,
  }) => _places({
    'action': 'search',
    'q': query.trim(),
    'lat': ?latitude,
    'lng': ?longitude,
    'lang': languageCode,
  });

  @override
  Future<List<PlaceModel>> getNearby(
    double latitude,
    double longitude, {
    required String languageCode,
  }) => _places({
    'action': 'nearby',
    'lat': latitude,
    'lng': longitude,
    'lang': languageCode,
  });

  @override
  Future<PlaceModel?> reverseGeocode(
    double latitude,
    double longitude, {
    required String languageCode,
  }) async {
    final places = await _places({
      'action': 'reverse',
      'lat': latitude,
      'lng': longitude,
      'lang': languageCode,
    });
    return places.isEmpty ? null : places.first;
  }

  Future<List<PlaceModel>> _places(Map<String, Object> body) =>
      Guard.run(() async {
        final response = await _client.functions.invoke(_function, body: body);
        final data = response.data;
        final places = JsonMapper.list(
          data is Map ? data['places'] : null,
          (item) =>
              item is Map<String, dynamic> ? PlaceModel.fromJson(item) : null,
        );
        return places ??
            (throw const FormatException('places answered without a list'));
      });
}
