import 'package:injectable/injectable.dart';

import '../../../../core/services/location_service.dart';
import '../../domain/entity/place_entity.dart';
import '../datasource/places_datasource.dart';
import '../datasource/recent_places_datasource.dart';
import '../enums/place_kind.dart';
import '../model/place_model.dart';

/// Places for the Add location screen: what the function finds, and the last places picked on this
/// device. Throws a `Failure` when the function cannot be reached.
abstract interface class PlacesRepository {
  Future<List<PlaceEntity>> search(
    String query, {
    DevicePosition? near,
    required String languageCode,
  });

  Future<List<PlaceEntity>> nearby(
    DevicePosition at, {
    required String languageCode,
  });

  /// The area and city [at] is in; null when nothing is known there.
  Future<PlaceEntity?> currentPlace(
    DevicePosition at, {
    required String languageCode,
  });

  /// The last places picked, newest first.
  List<PlaceEntity> recent();

  /// Puts [place] first in the recent list: once, and at most [maxRecent] places.
  Future<void> saveRecent(PlaceEntity place);
}

@LazySingleton(as: PlacesRepository)
class PlacesRepositoryImpl implements PlacesRepository {
  PlacesRepositoryImpl(this._places, this._recent);

  static const maxRecent = 5;

  final PlacesDatasource _places;
  final RecentPlacesDatasource _recent;

  @override
  Future<List<PlaceEntity>> search(
    String query, {
    DevicePosition? near,
    required String languageCode,
  }) async => _entities(
    await _places.searchPlaces(
      query,
      latitude: near?.latitude,
      longitude: near?.longitude,
      languageCode: languageCode,
    ),
  );

  @override
  Future<List<PlaceEntity>> nearby(
    DevicePosition at, {
    required String languageCode,
  }) async => _entities(
    await _places.getNearby(
      at.latitude,
      at.longitude,
      languageCode: languageCode,
    ),
  );

  @override
  Future<PlaceEntity?> currentPlace(
    DevicePosition at, {
    required String languageCode,
  }) async {
    final model = await _places.reverseGeocode(
      at.latitude,
      at.longitude,
      languageCode: languageCode,
    );
    return model == null ? null : _entity(model);
  }

  @override
  List<PlaceEntity> recent() => _entities(_recent.get());

  @override
  Future<void> saveRecent(PlaceEntity place) {
    final saved = _recent.get();
    final picked = PlaceModel(
      name: place.name,
      subtitle: place.subtitle,
      kind: place.kind,
    );
    return _recent.save(
      [
        picked,
        for (final other in saved)
          if (_key(other) != _key(picked)) other,
      ].take(maxRecent).toList(),
    );
  }

  String _key(PlaceModel place) =>
      '${place.name}|${place.subtitle}'.toLowerCase();

  List<PlaceEntity> _entities(List<PlaceModel> models) => [
    for (final model in models) ?_entity(model),
  ];

  /// A place with no name cannot be shown: it is dropped.
  PlaceEntity? _entity(PlaceModel model) {
    final name = model.name?.trim();
    if (name == null || name.isEmpty) return null;
    return PlaceEntity(
      name: name,
      subtitle: model.subtitle?.trim() ?? '',
      kind: model.kind ?? PlaceKind.poi,
      distanceKm: model.distanceKm,
    );
  }
}
