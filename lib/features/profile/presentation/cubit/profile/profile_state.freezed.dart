// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileState {

/// The header: the profile and its numbers.
 ProfileStatus get status; ProfilePageModel? get page;/// The header is the copy saved on the phone (offline): it has no numbers.
 bool get fromDevice; ProfileTab get tab;/// The active tab's grid.
 ProfileStatus get gridStatus; List<ProfileGridItemModel> get items; bool get hasMore; LoadMoreStatus get loadMore; bool get isRefreshing;/// Short-lived picture links by storage path.
 Map<String, String> get urls;/// Why the last pull to refresh failed; the screen shows it once.
 Failure? get refreshFailure;
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileStateCopyWith<ProfileState> get copyWith => _$ProfileStateCopyWithImpl<ProfileState>(this as ProfileState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProfileState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.fromDevice, _this.fromDevice) || other.fromDevice == _this.fromDevice)&&(identical(other.tab, _this.tab) || other.tab == _this.tab)&&(identical(other.gridStatus, _this.gridStatus) || other.gridStatus == _this.gridStatus)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.loadMore, _this.loadMore) || other.loadMore == _this.loadMore)&&(identical(other.isRefreshing, _this.isRefreshing) || other.isRefreshing == _this.isRefreshing)&&const DeepCollectionEquality().equals(other.urls, _this.urls)&&(identical(other.refreshFailure, _this.refreshFailure) || other.refreshFailure == _this.refreshFailure));
}


@override
int get hashCode {
  final _this = this as ProfileState;
  return Object.hash(runtimeType,_this.status,_this.page,_this.fromDevice,_this.tab,_this.gridStatus,const DeepCollectionEquality().hash(_this.items),_this.hasMore,_this.loadMore,_this.isRefreshing,const DeepCollectionEquality().hash(_this.urls),_this.refreshFailure);
}

@override
String toString() {
  final _this = this as ProfileState;
  return 'ProfileState(status: ${_this.status}, page: ${_this.page}, fromDevice: ${_this.fromDevice}, tab: ${_this.tab}, gridStatus: ${_this.gridStatus}, items: ${_this.items}, hasMore: ${_this.hasMore}, loadMore: ${_this.loadMore}, isRefreshing: ${_this.isRefreshing}, urls: ${_this.urls}, refreshFailure: ${_this.refreshFailure})';
}


}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res>  {
  factory $ProfileStateCopyWith(ProfileState value, $Res Function(ProfileState) _then) = _$ProfileStateCopyWithImpl;
@useResult
$Res call({
 ProfileStatus status, ProfilePageModel? page, bool fromDevice, ProfileTab tab, ProfileStatus gridStatus, List<ProfileGridItemModel> items, bool hasMore, LoadMoreStatus loadMore, bool isRefreshing, Map<String, String> urls, Failure? refreshFailure
});




}
/// @nodoc
class _$ProfileStateCopyWithImpl<$Res>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? page = freezed,Object? fromDevice = null,Object? tab = null,Object? gridStatus = null,Object? items = null,Object? hasMore = null,Object? loadMore = null,Object? isRefreshing = null,Object? urls = null,Object? refreshFailure = freezed,}) {
  return _then(ProfileState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as ProfilePageModel?,fromDevice: null == fromDevice ? _self.fromDevice : fromDevice // ignore: cast_nullable_to_non_nullable
as bool,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as ProfileTab,gridStatus: null == gridStatus ? _self.gridStatus : gridStatus // ignore: cast_nullable_to_non_nullable
as ProfileStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ProfileGridItemModel>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,loadMore: null == loadMore ? _self.loadMore : loadMore // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,urls: null == urls ? _self.urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, String>,refreshFailure: freezed == refreshFailure ? _self.refreshFailure : refreshFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProfileStatus status,  ProfilePageModel? page,  bool fromDevice,  ProfileTab tab,  ProfileStatus gridStatus,  List<ProfileGridItemModel> items,  bool hasMore,  LoadMoreStatus loadMore,  bool isRefreshing,  Map<String, String> urls,  Failure? refreshFailure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that.status,_that.page,_that.fromDevice,_that.tab,_that.gridStatus,_that.items,_that.hasMore,_that.loadMore,_that.isRefreshing,_that.urls,_that.refreshFailure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProfileStatus status,  ProfilePageModel? page,  bool fromDevice,  ProfileTab tab,  ProfileStatus gridStatus,  List<ProfileGridItemModel> items,  bool hasMore,  LoadMoreStatus loadMore,  bool isRefreshing,  Map<String, String> urls,  Failure? refreshFailure)  $default,) {final _that = this;
switch (_that) {
case _ProfileState():
return $default(_that.status,_that.page,_that.fromDevice,_that.tab,_that.gridStatus,_that.items,_that.hasMore,_that.loadMore,_that.isRefreshing,_that.urls,_that.refreshFailure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProfileStatus status,  ProfilePageModel? page,  bool fromDevice,  ProfileTab tab,  ProfileStatus gridStatus,  List<ProfileGridItemModel> items,  bool hasMore,  LoadMoreStatus loadMore,  bool isRefreshing,  Map<String, String> urls,  Failure? refreshFailure)?  $default,) {final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that.status,_that.page,_that.fromDevice,_that.tab,_that.gridStatus,_that.items,_that.hasMore,_that.loadMore,_that.isRefreshing,_that.urls,_that.refreshFailure);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileState implements ProfileState {
  const _ProfileState({this.status = ProfileStatus.loading, this.page, this.fromDevice = false, this.tab = ProfileTab.posts, this.gridStatus = ProfileStatus.loading,  List<ProfileGridItemModel> items = const <ProfileGridItemModel>[], this.hasMore = false, this.loadMore = LoadMoreStatus.idle, this.isRefreshing = false,  Map<String, String> urls = const <String, String>{}, this.refreshFailure}): _items = items,_urls = urls;
  

/// The header: the profile and its numbers.
@override@JsonKey() final  ProfileStatus status;
@override final  ProfilePageModel? page;
/// The header is the copy saved on the phone (offline): it has no numbers.
@override@JsonKey() final  bool fromDevice;
@override@JsonKey() final  ProfileTab tab;
/// The active tab's grid.
@override@JsonKey() final  ProfileStatus gridStatus;
 final  List<ProfileGridItemModel> _items;
@override@JsonKey() List<ProfileGridItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  LoadMoreStatus loadMore;
@override@JsonKey() final  bool isRefreshing;
/// Short-lived picture links by storage path.
 final  Map<String, String> _urls;
/// Short-lived picture links by storage path.
@override@JsonKey() Map<String, String> get urls {
  if (_urls is EqualUnmodifiableMapView) return _urls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_urls);
}

/// Why the last pull to refresh failed; the screen shows it once.
@override final  Failure? refreshFailure;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStateCopyWith<_ProfileState> get copyWith => __$ProfileStateCopyWithImpl<_ProfileState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileState&&(identical(other.status, status) || other.status == status)&&(identical(other.page, page) || other.page == page)&&(identical(other.fromDevice, fromDevice) || other.fromDevice == fromDevice)&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.gridStatus, gridStatus) || other.gridStatus == gridStatus)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.loadMore, loadMore) || other.loadMore == loadMore)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&const DeepCollectionEquality().equals(other.urls, _urls)&&(identical(other.refreshFailure, refreshFailure) || other.refreshFailure == refreshFailure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,page,fromDevice,tab,gridStatus,const DeepCollectionEquality().hash(_items),hasMore,loadMore,isRefreshing,const DeepCollectionEquality().hash(_urls),refreshFailure);
}

@override
String toString() {
    return 'ProfileState(status: $status, page: $page, fromDevice: $fromDevice, tab: $tab, gridStatus: $gridStatus, items: $items, hasMore: $hasMore, loadMore: $loadMore, isRefreshing: $isRefreshing, urls: $urls, refreshFailure: $refreshFailure)';
}


}

/// @nodoc
abstract mixin class _$ProfileStateCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateCopyWith(_ProfileState value, $Res Function(_ProfileState) _then) = __$ProfileStateCopyWithImpl;
@override @useResult
$Res call({
 ProfileStatus status, ProfilePageModel? page, bool fromDevice, ProfileTab tab, ProfileStatus gridStatus, List<ProfileGridItemModel> items, bool hasMore, LoadMoreStatus loadMore, bool isRefreshing, Map<String, String> urls, Failure? refreshFailure
});




}
/// @nodoc
class __$ProfileStateCopyWithImpl<$Res>
    implements _$ProfileStateCopyWith<$Res> {
  __$ProfileStateCopyWithImpl(this._self, this._then);

  final _ProfileState _self;
  final $Res Function(_ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? page = freezed,Object? fromDevice = null,Object? tab = null,Object? gridStatus = null,Object? items = null,Object? hasMore = null,Object? loadMore = null,Object? isRefreshing = null,Object? urls = null,Object? refreshFailure = freezed,}) {
  return _then(_ProfileState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as ProfilePageModel?,fromDevice: null == fromDevice ? _self.fromDevice : fromDevice // ignore: cast_nullable_to_non_nullable
as bool,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as ProfileTab,gridStatus: null == gridStatus ? _self.gridStatus : gridStatus // ignore: cast_nullable_to_non_nullable
as ProfileStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ProfileGridItemModel>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,loadMore: null == loadMore ? _self.loadMore : loadMore // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,urls: null == urls ? _self._urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, String>,refreshFailure: freezed == refreshFailure ? _self.refreshFailure : refreshFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
