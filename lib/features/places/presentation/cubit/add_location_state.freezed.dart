// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_location_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddLocationState {

/// The place already on the post, if any.
 String? get current; AddLocationStatus get status; PermissionAccess get access;/// Panel 4 shows instead of the lists.
 bool get showPrimer; bool get isOffline;/// The area and city the device is in ("Use current location").
 PlaceEntity? get currentPlace; List<PlaceEntity> get nearby; bool get isLoadingNearby; List<PlaceEntity> get recent; String get query; List<PlaceEntity> get results; LocationSearchStatus get searchStatus;/// One-shot: a place was picked or removed; the screen goes back with it.
 LocationChoice? get result;
/// Create a copy of AddLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddLocationStateCopyWith<AddLocationState> get copyWith => _$AddLocationStateCopyWithImpl<AddLocationState>(this as AddLocationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddLocationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddLocationState&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.access, _this.access) || other.access == _this.access)&&(identical(other.showPrimer, _this.showPrimer) || other.showPrimer == _this.showPrimer)&&(identical(other.isOffline, _this.isOffline) || other.isOffline == _this.isOffline)&&(identical(other.currentPlace, _this.currentPlace) || other.currentPlace == _this.currentPlace)&&const DeepCollectionEquality().equals(other.nearby, _this.nearby)&&(identical(other.isLoadingNearby, _this.isLoadingNearby) || other.isLoadingNearby == _this.isLoadingNearby)&&const DeepCollectionEquality().equals(other.recent, _this.recent)&&(identical(other.query, _this.query) || other.query == _this.query)&&const DeepCollectionEquality().equals(other.results, _this.results)&&(identical(other.searchStatus, _this.searchStatus) || other.searchStatus == _this.searchStatus)&&(identical(other.result, _this.result) || other.result == _this.result));
}


@override
int get hashCode {
  final _this = this as AddLocationState;
  return Object.hash(runtimeType,_this.current,_this.status,_this.access,_this.showPrimer,_this.isOffline,_this.currentPlace,const DeepCollectionEquality().hash(_this.nearby),_this.isLoadingNearby,const DeepCollectionEquality().hash(_this.recent),_this.query,const DeepCollectionEquality().hash(_this.results),_this.searchStatus,_this.result);
}

@override
String toString() {
  final _this = this as AddLocationState;
  return 'AddLocationState(current: ${_this.current}, status: ${_this.status}, access: ${_this.access}, showPrimer: ${_this.showPrimer}, isOffline: ${_this.isOffline}, currentPlace: ${_this.currentPlace}, nearby: ${_this.nearby}, isLoadingNearby: ${_this.isLoadingNearby}, recent: ${_this.recent}, query: ${_this.query}, results: ${_this.results}, searchStatus: ${_this.searchStatus}, result: ${_this.result})';
}


}

/// @nodoc
abstract mixin class $AddLocationStateCopyWith<$Res>  {
  factory $AddLocationStateCopyWith(AddLocationState value, $Res Function(AddLocationState) _then) = _$AddLocationStateCopyWithImpl;
@useResult
$Res call({
 String? current, AddLocationStatus status, PermissionAccess access, bool showPrimer, bool isOffline, PlaceEntity? currentPlace, List<PlaceEntity> nearby, bool isLoadingNearby, List<PlaceEntity> recent, String query, List<PlaceEntity> results, LocationSearchStatus searchStatus, LocationChoice? result
});




}
/// @nodoc
class _$AddLocationStateCopyWithImpl<$Res>
    implements $AddLocationStateCopyWith<$Res> {
  _$AddLocationStateCopyWithImpl(this._self, this._then);

  final AddLocationState _self;
  final $Res Function(AddLocationState) _then;

/// Create a copy of AddLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = freezed,Object? status = null,Object? access = null,Object? showPrimer = null,Object? isOffline = null,Object? currentPlace = freezed,Object? nearby = null,Object? isLoadingNearby = null,Object? recent = null,Object? query = null,Object? results = null,Object? searchStatus = null,Object? result = freezed,}) {
  return _then(AddLocationState(
current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AddLocationStatus,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as PermissionAccess,showPrimer: null == showPrimer ? _self.showPrimer : showPrimer // ignore: cast_nullable_to_non_nullable
as bool,isOffline: null == isOffline ? _self.isOffline : isOffline // ignore: cast_nullable_to_non_nullable
as bool,currentPlace: freezed == currentPlace ? _self.currentPlace : currentPlace // ignore: cast_nullable_to_non_nullable
as PlaceEntity?,nearby: null == nearby ? _self.nearby : nearby // ignore: cast_nullable_to_non_nullable
as List<PlaceEntity>,isLoadingNearby: null == isLoadingNearby ? _self.isLoadingNearby : isLoadingNearby // ignore: cast_nullable_to_non_nullable
as bool,recent: null == recent ? _self.recent : recent // ignore: cast_nullable_to_non_nullable
as List<PlaceEntity>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<PlaceEntity>,searchStatus: null == searchStatus ? _self.searchStatus : searchStatus // ignore: cast_nullable_to_non_nullable
as LocationSearchStatus,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as LocationChoice?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddLocationState].
extension AddLocationStatePatterns on AddLocationState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddLocationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddLocationState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddLocationState value)  $default,){
final _that = this;
switch (_that) {
case _AddLocationState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddLocationState value)?  $default,){
final _that = this;
switch (_that) {
case _AddLocationState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? current,  AddLocationStatus status,  PermissionAccess access,  bool showPrimer,  bool isOffline,  PlaceEntity? currentPlace,  List<PlaceEntity> nearby,  bool isLoadingNearby,  List<PlaceEntity> recent,  String query,  List<PlaceEntity> results,  LocationSearchStatus searchStatus,  LocationChoice? result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddLocationState() when $default != null:
return $default(_that.current,_that.status,_that.access,_that.showPrimer,_that.isOffline,_that.currentPlace,_that.nearby,_that.isLoadingNearby,_that.recent,_that.query,_that.results,_that.searchStatus,_that.result);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? current,  AddLocationStatus status,  PermissionAccess access,  bool showPrimer,  bool isOffline,  PlaceEntity? currentPlace,  List<PlaceEntity> nearby,  bool isLoadingNearby,  List<PlaceEntity> recent,  String query,  List<PlaceEntity> results,  LocationSearchStatus searchStatus,  LocationChoice? result)  $default,) {final _that = this;
switch (_that) {
case _AddLocationState():
return $default(_that.current,_that.status,_that.access,_that.showPrimer,_that.isOffline,_that.currentPlace,_that.nearby,_that.isLoadingNearby,_that.recent,_that.query,_that.results,_that.searchStatus,_that.result);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? current,  AddLocationStatus status,  PermissionAccess access,  bool showPrimer,  bool isOffline,  PlaceEntity? currentPlace,  List<PlaceEntity> nearby,  bool isLoadingNearby,  List<PlaceEntity> recent,  String query,  List<PlaceEntity> results,  LocationSearchStatus searchStatus,  LocationChoice? result)?  $default,) {final _that = this;
switch (_that) {
case _AddLocationState() when $default != null:
return $default(_that.current,_that.status,_that.access,_that.showPrimer,_that.isOffline,_that.currentPlace,_that.nearby,_that.isLoadingNearby,_that.recent,_that.query,_that.results,_that.searchStatus,_that.result);case _:
  return null;

}
}

}

/// @nodoc


class _AddLocationState extends AddLocationState {
  const _AddLocationState({this.current, this.status = AddLocationStatus.loading, this.access = PermissionAccess.denied, this.showPrimer = false, this.isOffline = false, this.currentPlace,  List<PlaceEntity> nearby = const [], this.isLoadingNearby = false,  List<PlaceEntity> recent = const [], this.query = '',  List<PlaceEntity> results = const [], this.searchStatus = LocationSearchStatus.idle, this.result}): _nearby = nearby,_recent = recent,_results = results,super._();
  

/// The place already on the post, if any.
@override final  String? current;
@override@JsonKey() final  AddLocationStatus status;
@override@JsonKey() final  PermissionAccess access;
/// Panel 4 shows instead of the lists.
@override@JsonKey() final  bool showPrimer;
@override@JsonKey() final  bool isOffline;
/// The area and city the device is in ("Use current location").
@override final  PlaceEntity? currentPlace;
 final  List<PlaceEntity> _nearby;
@override@JsonKey() List<PlaceEntity> get nearby {
  if (_nearby is EqualUnmodifiableListView) return _nearby;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nearby);
}

@override@JsonKey() final  bool isLoadingNearby;
 final  List<PlaceEntity> _recent;
@override@JsonKey() List<PlaceEntity> get recent {
  if (_recent is EqualUnmodifiableListView) return _recent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recent);
}

@override@JsonKey() final  String query;
 final  List<PlaceEntity> _results;
@override@JsonKey() List<PlaceEntity> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  LocationSearchStatus searchStatus;
/// One-shot: a place was picked or removed; the screen goes back with it.
@override final  LocationChoice? result;

/// Create a copy of AddLocationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddLocationStateCopyWith<_AddLocationState> get copyWith => __$AddLocationStateCopyWithImpl<_AddLocationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddLocationState&&(identical(other.current, current) || other.current == current)&&(identical(other.status, status) || other.status == status)&&(identical(other.access, access) || other.access == access)&&(identical(other.showPrimer, showPrimer) || other.showPrimer == showPrimer)&&(identical(other.isOffline, isOffline) || other.isOffline == isOffline)&&(identical(other.currentPlace, currentPlace) || other.currentPlace == currentPlace)&&const DeepCollectionEquality().equals(other.nearby, _nearby)&&(identical(other.isLoadingNearby, isLoadingNearby) || other.isLoadingNearby == isLoadingNearby)&&const DeepCollectionEquality().equals(other.recent, _recent)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.results, _results)&&(identical(other.searchStatus, searchStatus) || other.searchStatus == searchStatus)&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode {
    return Object.hash(runtimeType,current,status,access,showPrimer,isOffline,currentPlace,const DeepCollectionEquality().hash(_nearby),isLoadingNearby,const DeepCollectionEquality().hash(_recent),query,const DeepCollectionEquality().hash(_results),searchStatus,result);
}

@override
String toString() {
    return 'AddLocationState(current: $current, status: $status, access: $access, showPrimer: $showPrimer, isOffline: $isOffline, currentPlace: $currentPlace, nearby: $nearby, isLoadingNearby: $isLoadingNearby, recent: $recent, query: $query, results: $results, searchStatus: $searchStatus, result: $result)';
}


}

/// @nodoc
abstract mixin class _$AddLocationStateCopyWith<$Res> implements $AddLocationStateCopyWith<$Res> {
  factory _$AddLocationStateCopyWith(_AddLocationState value, $Res Function(_AddLocationState) _then) = __$AddLocationStateCopyWithImpl;
@override @useResult
$Res call({
 String? current, AddLocationStatus status, PermissionAccess access, bool showPrimer, bool isOffline, PlaceEntity? currentPlace, List<PlaceEntity> nearby, bool isLoadingNearby, List<PlaceEntity> recent, String query, List<PlaceEntity> results, LocationSearchStatus searchStatus, LocationChoice? result
});




}
/// @nodoc
class __$AddLocationStateCopyWithImpl<$Res>
    implements _$AddLocationStateCopyWith<$Res> {
  __$AddLocationStateCopyWithImpl(this._self, this._then);

  final _AddLocationState _self;
  final $Res Function(_AddLocationState) _then;

/// Create a copy of AddLocationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = freezed,Object? status = null,Object? access = null,Object? showPrimer = null,Object? isOffline = null,Object? currentPlace = freezed,Object? nearby = null,Object? isLoadingNearby = null,Object? recent = null,Object? query = null,Object? results = null,Object? searchStatus = null,Object? result = freezed,}) {
  return _then(_AddLocationState(
current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AddLocationStatus,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as PermissionAccess,showPrimer: null == showPrimer ? _self.showPrimer : showPrimer // ignore: cast_nullable_to_non_nullable
as bool,isOffline: null == isOffline ? _self.isOffline : isOffline // ignore: cast_nullable_to_non_nullable
as bool,currentPlace: freezed == currentPlace ? _self.currentPlace : currentPlace // ignore: cast_nullable_to_non_nullable
as PlaceEntity?,nearby: null == nearby ? _self._nearby : nearby // ignore: cast_nullable_to_non_nullable
as List<PlaceEntity>,isLoadingNearby: null == isLoadingNearby ? _self.isLoadingNearby : isLoadingNearby // ignore: cast_nullable_to_non_nullable
as bool,recent: null == recent ? _self._recent : recent // ignore: cast_nullable_to_non_nullable
as List<PlaceEntity>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<PlaceEntity>,searchStatus: null == searchStatus ? _self.searchStatus : searchStatus // ignore: cast_nullable_to_non_nullable
as LocationSearchStatus,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as LocationChoice?,
  ));
}


}

// dart format on
