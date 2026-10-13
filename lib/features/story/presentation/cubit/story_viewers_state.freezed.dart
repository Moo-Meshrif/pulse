// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_viewers_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoryViewersState {

 StoryViewersStatus get status;/// Newest first.
 List<StoryViewerModel> get viewers;/// The story's full view count (every row repeats it); the count the story card knew before the
/// first page arrived.
 int get total; bool get hasMore; bool get isLoadingMore;/// The last page failed: the list stays, a retry line shows at its end.
 bool get loadMoreFailed;
/// Create a copy of StoryViewersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryViewersStateCopyWith<StoryViewersState> get copyWith => _$StoryViewersStateCopyWithImpl<StoryViewersState>(this as StoryViewersState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StoryViewersState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryViewersState&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.viewers, _this.viewers)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.loadMoreFailed, _this.loadMoreFailed) || other.loadMoreFailed == _this.loadMoreFailed));
}


@override
int get hashCode {
  final _this = this as StoryViewersState;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.viewers),_this.total,_this.hasMore,_this.isLoadingMore,_this.loadMoreFailed);
}

@override
String toString() {
  final _this = this as StoryViewersState;
  return 'StoryViewersState(status: ${_this.status}, viewers: ${_this.viewers}, total: ${_this.total}, hasMore: ${_this.hasMore}, isLoadingMore: ${_this.isLoadingMore}, loadMoreFailed: ${_this.loadMoreFailed})';
}


}

/// @nodoc
abstract mixin class $StoryViewersStateCopyWith<$Res>  {
  factory $StoryViewersStateCopyWith(StoryViewersState value, $Res Function(StoryViewersState) _then) = _$StoryViewersStateCopyWithImpl;
@useResult
$Res call({
 StoryViewersStatus status, List<StoryViewerModel> viewers, int total, bool hasMore, bool isLoadingMore, bool loadMoreFailed
});




}
/// @nodoc
class _$StoryViewersStateCopyWithImpl<$Res>
    implements $StoryViewersStateCopyWith<$Res> {
  _$StoryViewersStateCopyWithImpl(this._self, this._then);

  final StoryViewersState _self;
  final $Res Function(StoryViewersState) _then;

/// Create a copy of StoryViewersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? viewers = null,Object? total = null,Object? hasMore = null,Object? isLoadingMore = null,Object? loadMoreFailed = null,}) {
  return _then(StoryViewersState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StoryViewersStatus,viewers: null == viewers ? _self.viewers : viewers // ignore: cast_nullable_to_non_nullable
as List<StoryViewerModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreFailed: null == loadMoreFailed ? _self.loadMoreFailed : loadMoreFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryViewersState].
extension StoryViewersStatePatterns on StoryViewersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryViewersState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryViewersState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryViewersState value)  $default,){
final _that = this;
switch (_that) {
case _StoryViewersState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryViewersState value)?  $default,){
final _that = this;
switch (_that) {
case _StoryViewersState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StoryViewersStatus status,  List<StoryViewerModel> viewers,  int total,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryViewersState() when $default != null:
return $default(_that.status,_that.viewers,_that.total,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StoryViewersStatus status,  List<StoryViewerModel> viewers,  int total,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed)  $default,) {final _that = this;
switch (_that) {
case _StoryViewersState():
return $default(_that.status,_that.viewers,_that.total,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StoryViewersStatus status,  List<StoryViewerModel> viewers,  int total,  bool hasMore,  bool isLoadingMore,  bool loadMoreFailed)?  $default,) {final _that = this;
switch (_that) {
case _StoryViewersState() when $default != null:
return $default(_that.status,_that.viewers,_that.total,_that.hasMore,_that.isLoadingMore,_that.loadMoreFailed);case _:
  return null;

}
}

}

/// @nodoc


class _StoryViewersState implements StoryViewersState {
  const _StoryViewersState({this.status = StoryViewersStatus.loading,  List<StoryViewerModel> viewers = const [], this.total = 0, this.hasMore = false, this.isLoadingMore = false, this.loadMoreFailed = false}): _viewers = viewers;
  

@override@JsonKey() final  StoryViewersStatus status;
/// Newest first.
 final  List<StoryViewerModel> _viewers;
/// Newest first.
@override@JsonKey() List<StoryViewerModel> get viewers {
  if (_viewers is EqualUnmodifiableListView) return _viewers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_viewers);
}

/// The story's full view count (every row repeats it); the count the story card knew before the
/// first page arrived.
@override@JsonKey() final  int total;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool isLoadingMore;
/// The last page failed: the list stays, a retry line shows at its end.
@override@JsonKey() final  bool loadMoreFailed;

/// Create a copy of StoryViewersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryViewersStateCopyWith<_StoryViewersState> get copyWith => __$StoryViewersStateCopyWithImpl<_StoryViewersState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryViewersState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.viewers, _viewers)&&(identical(other.total, total) || other.total == total)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.loadMoreFailed, loadMoreFailed) || other.loadMoreFailed == loadMoreFailed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_viewers),total,hasMore,isLoadingMore,loadMoreFailed);
}

@override
String toString() {
    return 'StoryViewersState(status: $status, viewers: $viewers, total: $total, hasMore: $hasMore, isLoadingMore: $isLoadingMore, loadMoreFailed: $loadMoreFailed)';
}


}

/// @nodoc
abstract mixin class _$StoryViewersStateCopyWith<$Res> implements $StoryViewersStateCopyWith<$Res> {
  factory _$StoryViewersStateCopyWith(_StoryViewersState value, $Res Function(_StoryViewersState) _then) = __$StoryViewersStateCopyWithImpl;
@override @useResult
$Res call({
 StoryViewersStatus status, List<StoryViewerModel> viewers, int total, bool hasMore, bool isLoadingMore, bool loadMoreFailed
});




}
/// @nodoc
class __$StoryViewersStateCopyWithImpl<$Res>
    implements _$StoryViewersStateCopyWith<$Res> {
  __$StoryViewersStateCopyWithImpl(this._self, this._then);

  final _StoryViewersState _self;
  final $Res Function(_StoryViewersState) _then;

/// Create a copy of StoryViewersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? viewers = null,Object? total = null,Object? hasMore = null,Object? isLoadingMore = null,Object? loadMoreFailed = null,}) {
  return _then(_StoryViewersState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StoryViewersStatus,viewers: null == viewers ? _self._viewers : viewers // ignore: cast_nullable_to_non_nullable
as List<StoryViewerModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreFailed: null == loadMoreFailed ? _self.loadMoreFailed : loadMoreFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
