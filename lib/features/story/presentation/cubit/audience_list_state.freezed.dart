// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audience_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AudienceListState {

 AudienceListStatus get status; AudienceTab get tab; String get query; List<AudiencePersonModel> get people; bool get hasMore; bool get isLoadingMore; bool get loadMoreFailed;/// How many were on the list when the screen opened.
 int get savedCount;/// What was tapped, by user id: the new state of that person, not yet saved.
 Map<String, bool> get changes;/// Where each tapped person stood on the server when first tapped (to tell add from remove).
 Map<String, bool> get original; bool get isSaving;/// One-shot: the list was saved; the screen closes.
 bool get isSaved;/// One-shot: saving failed.
 Failure? get failure;
/// Create a copy of AudienceListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudienceListStateCopyWith<AudienceListState> get copyWith => _$AudienceListStateCopyWithImpl<AudienceListState>(this as AudienceListState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AudienceListState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudienceListState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.tab, _this.tab) || other.tab == _this.tab)&&(identical(other.query, _this.query) || other.query == _this.query)&&const DeepCollectionEquality().equals(other.people, _this.people)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.loadMoreFailed, _this.loadMoreFailed) || other.loadMoreFailed == _this.loadMoreFailed)&&(identical(other.savedCount, _this.savedCount) || other.savedCount == _this.savedCount)&&const DeepCollectionEquality().equals(other.changes, _this.changes)&&const DeepCollectionEquality().equals(other.original, _this.original)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.isSaved, _this.isSaved) || other.isSaved == _this.isSaved)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as AudienceListState;
  return Object.hash(runtimeType,_this.status,_this.tab,_this.query,const DeepCollectionEquality().hash(_this.people),_this.hasMore,_this.isLoadingMore,_this.loadMoreFailed,_this.savedCount,const DeepCollectionEquality().hash(_this.changes),const DeepCollectionEquality().hash(_this.original),_this.isSaving,_this.isSaved,_this.failure);
}

@override
String toString() {
  final _this = this as AudienceListState;
  return 'AudienceListState(status: ${_this.status}, tab: ${_this.tab}, query: ${_this.query}, people: ${_this.people}, hasMore: ${_this.hasMore}, isLoadingMore: ${_this.isLoadingMore}, loadMoreFailed: ${_this.loadMoreFailed}, savedCount: ${_this.savedCount}, changes: ${_this.changes}, original: ${_this.original}, isSaving: ${_this.isSaving}, isSaved: ${_this.isSaved}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $AudienceListStateCopyWith<$Res>  {
  factory $AudienceListStateCopyWith(AudienceListState value, $Res Function(AudienceListState) _then) = _$AudienceListStateCopyWithImpl;
@useResult
$Res call({
 AudienceListStatus status, AudienceTab tab, String query, List<AudiencePersonModel> people, bool hasMore, bool isLoadingMore, bool loadMoreFailed, int savedCount, Map<String, bool> changes, Map<String, bool> original, bool isSaving, bool isSaved, Failure? failure
});




}
/// @nodoc
class _$AudienceListStateCopyWithImpl<$Res>
    implements $AudienceListStateCopyWith<$Res> {
  _$AudienceListStateCopyWithImpl(this._self, this._then);

  final AudienceListState _self;
  final $Res Function(AudienceListState) _then;

/// Create a copy of AudienceListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? tab = null,Object? query = null,Object? people = null,Object? hasMore = null,Object? isLoadingMore = null,Object? loadMoreFailed = null,Object? savedCount = null,Object? changes = null,Object? original = null,Object? isSaving = null,Object? isSaved = null,Object? failure = freezed,}) {
  return _then(AudienceListState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudienceListStatus,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as AudienceTab,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as List<AudiencePersonModel>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreFailed: null == loadMoreFailed ? _self.loadMoreFailed : loadMoreFailed // ignore: cast_nullable_to_non_nullable
as bool,savedCount: null == savedCount ? _self.savedCount : savedCount // ignore: cast_nullable_to_non_nullable
as int,changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,original: null == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [AudienceListState].
extension AudienceListStatePatterns on AudienceListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudienceListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudienceListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudienceListState value)  $default,){
final _that = this;
switch (_that) {
case _AudienceListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudienceListState value)?  $default,){
final _that = this;
switch (_that) {
case _AudienceListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AudienceListStatus status,  AudienceTab tab,  String query,  List<AudiencePersonModel> people,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed,  int savedCount,  Map<String, bool> changes,  Map<String, bool> original,  bool isSaving,  bool isSaved,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudienceListState() when $default != null:
return $default(_that.status,_that.tab,_that.query,_that.people,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed,_that.savedCount,_that.changes,_that.original,_that.isSaving,_that.isSaved,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AudienceListStatus status,  AudienceTab tab,  String query,  List<AudiencePersonModel> people,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed,  int savedCount,  Map<String, bool> changes,  Map<String, bool> original,  bool isSaving,  bool isSaved,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _AudienceListState():
return $default(_that.status,_that.tab,_that.query,_that.people,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed,_that.savedCount,_that.changes,_that.original,_that.isSaving,_that.isSaved,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AudienceListStatus status,  AudienceTab tab,  String query,  List<AudiencePersonModel> people,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed,  int savedCount,  Map<String, bool> changes,  Map<String, bool> original,  bool isSaving,  bool isSaved,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _AudienceListState() when $default != null:
return $default(_that.status,_that.tab,_that.query,_that.people,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed,_that.savedCount,_that.changes,_that.original,_that.isSaving,_that.isSaved,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _AudienceListState extends AudienceListState {
  const _AudienceListState({this.status = AudienceListStatus.loading, this.tab = AudienceTab.suggested, this.query = '',  List<AudiencePersonModel> people = const [], this.hasMore = false, this.isLoadingMore = false, this.loadMoreFailed = false, this.savedCount = 0,  Map<String, bool> changes = const {},  Map<String, bool> original = const {}, this.isSaving = false, this.isSaved = false, this.failure}): _people = people,_changes = changes,_original = original,super._();
  

@override@JsonKey() final  AudienceListStatus status;
@override@JsonKey() final  AudienceTab tab;
@override@JsonKey() final  String query;
 final  List<AudiencePersonModel> _people;
@override@JsonKey() List<AudiencePersonModel> get people {
  if (_people is EqualUnmodifiableListView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_people);
}

@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  bool loadMoreFailed;
/// How many were on the list when the screen opened.
@override@JsonKey() final  int savedCount;
/// What was tapped, by user id: the new state of that person, not yet saved.
 final  Map<String, bool> _changes;
/// What was tapped, by user id: the new state of that person, not yet saved.
@override@JsonKey() Map<String, bool> get changes {
  if (_changes is EqualUnmodifiableMapView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_changes);
}

/// Where each tapped person stood on the server when first tapped (to tell add from remove).
 final  Map<String, bool> _original;
/// Where each tapped person stood on the server when first tapped (to tell add from remove).
@override@JsonKey() Map<String, bool> get original {
  if (_original is EqualUnmodifiableMapView) return _original;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_original);
}

@override@JsonKey() final  bool isSaving;
/// One-shot: the list was saved; the screen closes.
@override@JsonKey() final  bool isSaved;
/// One-shot: saving failed.
@override final  Failure? failure;

/// Create a copy of AudienceListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudienceListStateCopyWith<_AudienceListState> get copyWith => __$AudienceListStateCopyWithImpl<_AudienceListState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudienceListState&&(identical(other.status, status) || other.status == status)&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.people, _people)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.loadMoreFailed, loadMoreFailed) || other.loadMoreFailed == loadMoreFailed)&&(identical(other.savedCount, savedCount) || other.savedCount == savedCount)&&const DeepCollectionEquality().equals(other.changes, _changes)&&const DeepCollectionEquality().equals(other.original, _original)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,tab,query,const DeepCollectionEquality().hash(_people),hasMore,isLoadingMore,loadMoreFailed,savedCount,const DeepCollectionEquality().hash(_changes),const DeepCollectionEquality().hash(_original),isSaving,isSaved,failure);
}

@override
String toString() {
    return 'AudienceListState(status: $status, tab: $tab, query: $query, people: $people, hasMore: $hasMore, isLoadingMore: $isLoadingMore, loadMoreFailed: $loadMoreFailed, savedCount: $savedCount, changes: $changes, original: $original, isSaving: $isSaving, isSaved: $isSaved, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$AudienceListStateCopyWith<$Res> implements $AudienceListStateCopyWith<$Res> {
  factory _$AudienceListStateCopyWith(_AudienceListState value, $Res Function(_AudienceListState) _then) = __$AudienceListStateCopyWithImpl;
@override @useResult
$Res call({
 AudienceListStatus status, AudienceTab tab, String query, List<AudiencePersonModel> people, bool hasMore, bool isLoadingMore, bool loadMoreFailed, int savedCount, Map<String, bool> changes, Map<String, bool> original, bool isSaving, bool isSaved, Failure? failure
});




}
/// @nodoc
class __$AudienceListStateCopyWithImpl<$Res>
    implements _$AudienceListStateCopyWith<$Res> {
  __$AudienceListStateCopyWithImpl(this._self, this._then);

  final _AudienceListState _self;
  final $Res Function(_AudienceListState) _then;

/// Create a copy of AudienceListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? tab = null,Object? query = null,Object? people = null,Object? hasMore = null,Object? isLoadingMore = null,Object? loadMoreFailed = null,Object? savedCount = null,Object? changes = null,Object? original = null,Object? isSaving = null,Object? isSaved = null,Object? failure = freezed,}) {
  return _then(_AudienceListState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudienceListStatus,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as AudienceTab,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as List<AudiencePersonModel>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreFailed: null == loadMoreFailed ? _self.loadMoreFailed : loadMoreFailed // ignore: cast_nullable_to_non_nullable
as bool,savedCount: null == savedCount ? _self.savedCount : savedCount // ignore: cast_nullable_to_non_nullable
as int,changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,original: null == original ? _self._original : original // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
