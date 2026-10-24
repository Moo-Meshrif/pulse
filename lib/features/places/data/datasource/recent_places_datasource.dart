import 'package:injectable/injectable.dart';

import '../../../../core/services/storage/local_storage.dart';
import '../../../../core/services/storage/storage_keys.dart';
import '../model/place_model.dart';

/// The places picked as a location (a post's, a story's), kept on the device, newest first. Widgets never touch it.
@lazySingleton
class RecentPlacesDatasource {
  RecentPlacesDatasource(this._storage);

  final LocalStorageService _storage;

  List<PlaceModel> get() {
    final stored =
        _storage.getValue<List<String>>(StorageKeys.recentPlaces) ?? const [];
    return [for (final raw in stored) ?PlaceModel.fromStored(raw)];
  }

  Future<void> save(List<PlaceModel> places) => _storage.setValue<List<String>>(
    StorageKeys.recentPlaces,
    places.map((place) => place.toStored()).toList(),
  );
}
