// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'other_profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OtherProfileState {

 ProfileStatus get status; ProfilePageModel? get page; bool get notFound; FollowStatus get follow; int get followers; bool get busy; int get tab; ProfileStatus get gridStatus; List<ProfileGridItemModel> get items; Map<String, String> get urls; bool get hasMore; LoadMoreStatus get more; bool get refreshing; Map<String, dynamic> get mutual; Failure? get failure; bool get requestSent;
/// Create a copy of OtherProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtherProfileStateCopyWith<OtherProfileState> get copyWith => _$OtherProfileStateCopyWithImpl<OtherProfileState>(this as OtherProfileState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OtherProfileState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtherProfileState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.notFound, _this.notFound) || other.notFound == _this.notFound)&&(identical(other.follow, _this.follow) || other.follow == _this.follow)&&(identical(other.followers, _this.followers) || other.followers == _this.followers)&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&(identical(other.tab, _this.tab) || other.tab == _this.tab)&&(identical(other.gridStatus, _this.gridStatus) || other.gridStatus == _this.gridStatus)&&const DeepCollectionEquality().equals(other.items, _this.items)&&const DeepCollectionEquality().equals(other.urls, _this.urls)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.more, _this.more) || other.more == _this.more)&&(identical(other.refreshing, _this.refreshing) || other.refreshing == _this.refreshing)&&const DeepCollectionEquality().equals(other.mutual, _this.mutual)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.requestSent, _this.requestSent) || other.requestSent == _this.requestSent));
}


@override
int get hashCode {
  final _this = this as OtherProfileState;
  return Object.hash(runtimeType,_this.status,_this.page,_this.notFound,_this.follow,_this.followers,_this.busy,_this.tab,_this.gridStatus,const DeepCollectionEquality().hash(_this.items),const DeepCollectionEquality().hash(_this.urls),_this.hasMore,_this.more,_this.refreshing,const DeepCollectionEquality().hash(_this.mutual),_this.failure,_this.requestSent);
}

@override
String toString() {
  final _this = this as OtherProfileState;
  return 'OtherProfileState(status: ${_this.status}, page: ${_this.page}, notFound: ${_this.notFound}, follow: ${_this.follow}, followers: ${_this.followers}, busy: ${_this.busy}, tab: ${_this.tab}, gridStatus: ${_this.gridStatus}, items: ${_this.items}, urls: ${_this.urls}, hasMore: ${_this.hasMore}, more: ${_this.more}, refreshing: ${_this.refreshing}, mutual: ${_this.mutual}, failure: ${_this.failure}, requestSent: ${_this.requestSent})';
}


}

/// @nodoc
abstract mixin class $OtherProfileStateCopyWith<$Res>  {
  factory $OtherProfileStateCopyWith(OtherProfileState value, $Res Function(OtherProfileState) _then) = _$OtherProfileStateCopyWithImpl;
@useResult
$Res call({
 ProfileStatus status, ProfilePageModel? page, bool notFound, FollowStatus follow, int followers, bool busy, int tab, ProfileStatus gridStatus, List<ProfileGridItemModel> items, Map<String, String> urls, bool hasMore, LoadMoreStatus more, bool refreshing, Map<String, dynamic> mutual, Failure? failure, bool requestSent
});




}
/// @nodoc
class _$OtherProfileStateCopyWithImpl<$Res>
    implements $OtherProfileStateCopyWith<$Res> {
  _$OtherProfileStateCopyWithImpl(this._self, this._then);

  final OtherProfileState _self;
  final $Res Function(OtherProfileState) _then;

/// Create a copy of OtherProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? page = freezed,Object? notFound = null,Object? follow = null,Object? followers = null,Object? busy = null,Object? tab = null,Object? gridStatus = null,Object? items = null,Object? urls = null,Object? hasMore = null,Object? more = null,Object? refreshing = null,Object? mutual = null,Object? failure = freezed,Object? requestSent = null,}) {
  return _then(OtherProfileState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as ProfilePageModel?,notFound: null == notFound ? _self.notFound : notFound // ignore: cast_nullable_to_non_nullable
as bool,follow: null == follow ? _self.follow : follow // ignore: cast_nullable_to_non_nullable
as FollowStatus,followers: null == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as int,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as int,gridStatus: null == gridStatus ? _self.gridStatus : gridStatus // ignore: cast_nullable_to_non_nullable
as ProfileStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ProfileGridItemModel>,urls: null == urls ? _self.urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,more: null == more ? _self.more : more // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,mutual: null == mutual ? _self.mutual : mutual // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,requestSent: null == requestSent ? _self.requestSent : requestSent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OtherProfileState].
extension OtherProfileStatePatterns on OtherProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtherProfileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtherProfileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtherProfileState value)  $default,){
final _that = this;
switch (_that) {
case _OtherProfileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtherProfileState value)?  $default,){
final _that = this;
switch (_that) {
case _OtherProfileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProfileStatus status,  ProfilePageModel? page,  bool notFound,  FollowStatus follow,  int followers,  bool busy,  int tab,  ProfileStatus gridStatus,  List<ProfileGridItemModel> items,  Map<String, String> urls,  bool hasMore,  LoadMoreStatus more,  bool refreshing,  Map<String, dynamic> mutual,  Failure? failure,  bool requestSent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtherProfileState() when $default != null:
return $default(_that.status,_that.page,_that.notFound,_that.follow,_that.followers,_that.busy,_that.tab,_that.gridStatus,_that.items,_that.urls,_that.hasMore,_that.more,_that.refreshing,_that.mutual,_that.failure,_that.requestSent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProfileStatus status,  ProfilePageModel? page,  bool notFound,  FollowStatus follow,  int followers,  bool busy,  int tab,  ProfileStatus gridStatus,  List<ProfileGridItemModel> items,  Map<String, String> urls,  bool hasMore,  LoadMoreStatus more,  bool refreshing,  Map<String, dynamic> mutual,  Failure? failure,  bool requestSent)  $default,) {final _that = this;
switch (_that) {
case _OtherProfileState():
return $default(_that.status,_that.page,_that.notFound,_that.follow,_that.followers,_that.busy,_that.tab,_that.gridStatus,_that.items,_that.urls,_that.hasMore,_that.more,_that.refreshing,_that.mutual,_that.failure,_that.requestSent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProfileStatus status,  ProfilePageModel? page,  bool notFound,  FollowStatus follow,  int followers,  bool busy,  int tab,  ProfileStatus gridStatus,  List<ProfileGridItemModel> items,  Map<String, String> urls,  bool hasMore,  LoadMoreStatus more,  bool refreshing,  Map<String, dynamic> mutual,  Failure? failure,  bool requestSent)?  $default,) {final _that = this;
switch (_that) {
case _OtherProfileState() when $default != null:
return $default(_that.status,_that.page,_that.notFound,_that.follow,_that.followers,_that.busy,_that.tab,_that.gridStatus,_that.items,_that.urls,_that.hasMore,_that.more,_that.refreshing,_that.mutual,_that.failure,_that.requestSent);case _:
  return null;

}
}

}

/// @nodoc


class _OtherProfileState implements OtherProfileState {
  const _OtherProfileState({this.status = ProfileStatus.loading, this.page, this.notFound = false, this.follow = FollowStatus.none, this.followers = 0, this.busy = false, this.tab = 0, this.gridStatus = ProfileStatus.loading,  List<ProfileGridItemModel> items = const <ProfileGridItemModel>[],  Map<String, String> urls = const <String, String>{}, this.hasMore = false, this.more = LoadMoreStatus.idle, this.refreshing = false,  Map<String, dynamic> mutual = const <String, dynamic>{}, this.failure, this.requestSent = false}): _items = items,_urls = urls,_mutual = mutual;
  

@override@JsonKey() final  ProfileStatus status;
@override final  ProfilePageModel? page;
@override@JsonKey() final  bool notFound;
@override@JsonKey() final  FollowStatus follow;
@override@JsonKey() final  int followers;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  int tab;
@override@JsonKey() final  ProfileStatus gridStatus;
 final  List<ProfileGridItemModel> _items;
@override@JsonKey() List<ProfileGridItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  Map<String, String> _urls;
@override@JsonKey() Map<String, String> get urls {
  if (_urls is EqualUnmodifiableMapView) return _urls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_urls);
}

@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  LoadMoreStatus more;
@override@JsonKey() final  bool refreshing;
 final  Map<String, dynamic> _mutual;
@override@JsonKey() Map<String, dynamic> get mutual {
  if (_mutual is EqualUnmodifiableMapView) return _mutual;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_mutual);
}

@override final  Failure? failure;
@override@JsonKey() final  bool requestSent;

/// Create a copy of OtherProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtherProfileStateCopyWith<_OtherProfileState> get copyWith => __$OtherProfileStateCopyWithImpl<_OtherProfileState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtherProfileState&&(identical(other.status, status) || other.status == status)&&(identical(other.page, page) || other.page == page)&&(identical(other.notFound, notFound) || other.notFound == notFound)&&(identical(other.follow, follow) || other.follow == follow)&&(identical(other.followers, followers) || other.followers == followers)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.gridStatus, gridStatus) || other.gridStatus == gridStatus)&&const DeepCollectionEquality().equals(other.items, _items)&&const DeepCollectionEquality().equals(other.urls, _urls)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.more, more) || other.more == more)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&const DeepCollectionEquality().equals(other.mutual, _mutual)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.requestSent, requestSent) || other.requestSent == requestSent));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,page,notFound,follow,followers,busy,tab,gridStatus,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_urls),hasMore,more,refreshing,const DeepCollectionEquality().hash(_mutual),failure,requestSent);
}

@override
String toString() {
    return 'OtherProfileState(status: $status, page: $page, notFound: $notFound, follow: $follow, followers: $followers, busy: $busy, tab: $tab, gridStatus: $gridStatus, items: $items, urls: $urls, hasMore: $hasMore, more: $more, refreshing: $refreshing, mutual: $mutual, failure: $failure, requestSent: $requestSent)';
}


}

/// @nodoc
abstract mixin class _$OtherProfileStateCopyWith<$Res> implements $OtherProfileStateCopyWith<$Res> {
  factory _$OtherProfileStateCopyWith(_OtherProfileState value, $Res Function(_OtherProfileState) _then) = __$OtherProfileStateCopyWithImpl;
@override @useResult
$Res call({
 ProfileStatus status, ProfilePageModel? page, bool notFound, FollowStatus follow, int followers, bool busy, int tab, ProfileStatus gridStatus, List<ProfileGridItemModel> items, Map<String, String> urls, bool hasMore, LoadMoreStatus more, bool refreshing, Map<String, dynamic> mutual, Failure? failure, bool requestSent
});




}
/// @nodoc
class __$OtherProfileStateCopyWithImpl<$Res>
    implements _$OtherProfileStateCopyWith<$Res> {
  __$OtherProfileStateCopyWithImpl(this._self, this._then);

  final _OtherProfileState _self;
  final $Res Function(_OtherProfileState) _then;

/// Create a copy of OtherProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? page = freezed,Object? notFound = null,Object? follow = null,Object? followers = null,Object? busy = null,Object? tab = null,Object? gridStatus = null,Object? items = null,Object? urls = null,Object? hasMore = null,Object? more = null,Object? refreshing = null,Object? mutual = null,Object? failure = freezed,Object? requestSent = null,}) {
  return _then(_OtherProfileState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as ProfilePageModel?,notFound: null == notFound ? _self.notFound : notFound // ignore: cast_nullable_to_non_nullable
as bool,follow: null == follow ? _self.follow : follow // ignore: cast_nullable_to_non_nullable
as FollowStatus,followers: null == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as int,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as int,gridStatus: null == gridStatus ? _self.gridStatus : gridStatus // ignore: cast_nullable_to_non_nullable
as ProfileStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ProfileGridItemModel>,urls: null == urls ? _self._urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,more: null == more ? _self.more : more // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,mutual: null == mutual ? _self._mutual : mutual // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,requestSent: null == requestSent ? _self.requestSent : requestSent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
