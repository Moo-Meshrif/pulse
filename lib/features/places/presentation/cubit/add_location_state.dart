import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/permission_access.dart';
import '../../../../core/utils/location_choice.dart';
import '../../domain/entity/place_entity.dart';
import '../utils/add_location_limits.dart';
import '../utils/enums/add_location_status.dart';
import '../utils/enums/location_search_status.dart';

part 'add_location_state.freezed.dart';

@freezed
abstract class AddLocationState with _$AddLocationState {
  const AddLocationState._();

  const factory AddLocationState({
    /// The place already on the post, if any.
    String? current,
    @Default(AddLocationStatus.loading) AddLocationStatus status,
    @Default(PermissionAccess.denied) PermissionAccess access,

    /// Panel 4 shows instead of the lists.
    @Default(false) bool showPrimer,
    @Default(false) bool isOffline,

    /// The area and city the device is in ("Use current location").
    PlaceEntity? currentPlace,
    @Default([]) List<PlaceEntity> nearby,
    @Default(false) bool isLoadingNearby,
    @Default([]) List<PlaceEntity> recent,
    @Default('') String query,
    @Default([]) List<PlaceEntity> results,
    @Default(LocationSearchStatus.idle) LocationSearchStatus searchStatus,

    /// One-shot: a place was picked or removed; the screen goes back with it.
    LocationChoice? result,
  }) = _AddLocationState;

  bool get isLoading => status == AddLocationStatus.loading;

  bool get isSearching =>
      query.trim().length >= AddLocationLimits.minQueryLength;

  bool get hasLocationAccess => access == PermissionAccess.granted;

  /// Nearby places cannot be shown, so the search field takes the focus.
  bool get shouldAutofocusSearch => !isLoading && !hasLocationAccess;
}
