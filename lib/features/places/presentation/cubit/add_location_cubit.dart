import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/enums/permission_access.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../../core/utils/location_choice.dart';
import '../../data/datasource/location_primer_datasource.dart';
import '../../data/repository/places_repository.dart';
import '../../domain/entity/place_entity.dart';
import '../utils/add_location_limits.dart';
import '../utils/enums/add_location_status.dart';
import '../utils/enums/location_search_status.dart';
import 'add_location_state.dart';

/// The Add location screen (docs/specs/post/screens/s3-add-location.md): where the device is, the places
/// near it, the last places picked, and search.
@injectable
class AddLocationCubit extends BaseCubit<AddLocationState> {
  AddLocationCubit(
    this._places,
    this._location,
    this._connectivity,
    this._primer,
    @factoryParam String? current,
  ) : super(AddLocationState(current: current, recent: _places.recent()));

  final PlacesRepository _places;
  final LocationService _location;
  final ConnectivityService _connectivity;
  final LocationPrimerDatasource _primer;

  Timer? _debounce;
  StreamSubscription<void>? _connectionHints;

  /// A newer search, or a cleared one, makes an older answer stale.
  int _request = 0;

  String _languageCode = 'en';

  /// Where the device was when nearby loaded; searches use it to rank what is close.
  DevicePosition? _position;

  /// Reads the permission and connection and shows the first panel. [languageCode] is the app's language.
  Future<void> start(String languageCode) async {
    _languageCode = languageCode;
    final offline = await _connectivity.isOffline();
    final access = await _location.permission();
    emit(
      state.copyWith(
        status: AddLocationStatus.ready,
        access: access,
        isOffline: offline,
        showPrimer: _needsPrimer(access),
      ),
    );
    _connectionHints ??= _connectivity.connectionHints.listen(
      (_) => refreshConnection(),
    );
    if (access == PermissionAccess.granted) await _loadNearby();
  }

  /// The primer button: asks for the permission, or opens Settings when only Settings can turn it on.
  Future<void> allowLocation() async {
    if (state.access == PermissionAccess.blocked) {
      await _location.openSettings();
      return;
    }
    await _location.request();
    await recheckAccess();
  }

  /// "Not now": search and recent only, and the primer does not come back.
  Future<void> notNow() async {
    emit(state.copyWith(showPrimer: false));
    await _primer.markDismissed();
  }

  /// The permission may have changed outside the app (Settings): read it again.
  Future<void> recheckAccess() async {
    final access = await _location.permission();
    if (access == state.access) return;
    emit(
      state.copyWith(
        access: access,
        showPrimer: access == PermissionAccess.granted
            ? false
            : state.showPrimer,
      ),
    );
    if (access == PermissionAccess.granted) await _loadNearby();
  }

  /// The connection may be back (or gone): search comes back with it, and so does nearby.
  Future<void> refreshConnection() async {
    final offline = await _connectivity.isOffline();
    if (offline == state.isOffline) return;
    emit(state.copyWith(isOffline: offline));
    if (!offline && state.hasLocationAccess && state.nearby.isEmpty) {
      await _loadNearby();
    }
  }

  /// Search as you type: one request per pause, from [AddLocationLimits.minQueryLength] characters.
  void queryChanged(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _request++;
    if (!state.isSearching) {
      emit(
        state.copyWith(results: [], searchStatus: LocationSearchStatus.idle),
      );
      return;
    }
    _debounce = Timer(AddLocationLimits.searchDelay, _search);
  }

  /// The picked place goes first in recent, then the screen goes back with its name.
  Future<void> select(PlaceEntity place) => run(
    () => _places.saveRecent(place),
    onSuccess: (_) => _picked(place),
    onFailure: (_) => _picked(place),
  );

  void remove() => emit(state.copyWith(result: const LocationChoice(null)));

  AddLocationState _picked(PlaceEntity place) =>
      state.copyWith(result: LocationChoice(place.displayName));

  bool _needsPrimer(PermissionAccess access) =>
      (access == PermissionAccess.denied ||
          access == PermissionAccess.blocked) &&
      !_primer.isDismissed;

  Future<void> _loadNearby() => run(
    () async {
      final position = await _location.currentPosition();
      if (position == null) return null;
      _position = position;
      final (nearby, here) = await (
        _places.nearby(position, languageCode: _languageCode),
        _places.currentPlace(position, languageCode: _languageCode),
      ).wait;
      return (nearby, here);
    },
    prevent: state.isLoadingNearby,
    loading: state.copyWith(isLoadingNearby: true),
    onSuccess: (found) => found == null
        ? state.copyWith(isLoadingNearby: false)
        : state.copyWith(
            isLoadingNearby: false,
            nearby: found.$1,
            currentPlace: found.$2,
          ),
    onFailure: (failure) => state.copyWith(
      isLoadingNearby: false,
      isOffline: state.isOffline || _isConnectionFailure(failure),
    ),
  );

  Future<void> _search() {
    final request = _request;
    return run(
      () => _places.search(
        state.query.trim(),
        near: _position,
        languageCode: _languageCode,
      ),
      prevent: state.isOffline,
      loading: state.copyWith(searchStatus: LocationSearchStatus.loading),
      onSuccess: (results) => request != _request
          ? null
          : state.copyWith(
              results: results,
              searchStatus: LocationSearchStatus.ready,
            ),
      onFailure: (failure) => request != _request
          ? null
          : state.copyWith(
              searchStatus: LocationSearchStatus.failed,
              isOffline: _isConnectionFailure(failure),
            ),
    );
  }

  bool _isConnectionFailure(Failure failure) =>
      failure is NetworkFailure || failure is TimeoutFailure;

  @override
  Future<void> close() {
    _debounce?.cancel();
    _connectionHints?.cancel();
    return super.close();
  }
}
