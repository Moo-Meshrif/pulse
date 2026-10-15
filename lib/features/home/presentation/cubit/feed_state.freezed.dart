// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedState {

/// The signed-in person, to tell their own posts apart.
 String? get userId; FeedStatus get status; List<FeedPost> get posts;/// Where the next page starts; null on the last page.
 FeedCursorEntity? get nextCursor; bool get isRefreshing; LoadMoreStatus get loadMore;/// Posts whose delete can still be undone: they are not shown, and when they were the last ones the
/// empty page shows.
 Set<String> get pendingDeleteIds;/// Counts the times the posts were replaced (first load, refresh): what was done to the old ones
/// no longer applies.
 int get generation;/// Why the first load failed.
 Failure? get failure;/// One-shot: a refresh failed; the posts on screen stay.
 Failure? get refreshFailure;
/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedStateCopyWith<FeedState> get copyWith => _$FeedStateCopyWithImpl<FeedState>(this as FeedState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FeedState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedState&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.posts, _this.posts)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor)&&(identical(other.isRefreshing, _this.isRefreshing) || other.isRefreshing == _this.isRefreshing)&&(identical(other.loadMore, _this.loadMore) || other.loadMore == _this.loadMore)&&const DeepCollectionEquality().equals(other.pendingDeleteIds, _this.pendingDeleteIds)&&(identical(other.generation, _this.generation) || other.generation == _this.generation)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.refreshFailure, _this.refreshFailure) || other.refreshFailure == _this.refreshFailure));
}


@override
int get hashCode {
  final _this = this as FeedState;
  return Object.hash(runtimeType,_this.userId,_this.status,const DeepCollectionEquality().hash(_this.posts),_this.nextCursor,_this.isRefreshing,_this.loadMore,const DeepCollectionEquality().hash(_this.pendingDeleteIds),_this.generation,_this.failure,_this.refreshFailure);
}

@override
String toString() {
  final _this = this as FeedState;
  return 'FeedState(userId: ${_this.userId}, status: ${_this.status}, posts: ${_this.posts}, nextCursor: ${_this.nextCursor}, isRefreshing: ${_this.isRefreshing}, loadMore: ${_this.loadMore}, pendingDeleteIds: ${_this.pendingDeleteIds}, generation: ${_this.generation}, failure: ${_this.failure}, refreshFailure: ${_this.refreshFailure})';
}


}

/// @nodoc
abstract mixin class $FeedStateCopyWith<$Res>  {
  factory $FeedStateCopyWith(FeedState value, $Res Function(FeedState) _then) = _$FeedStateCopyWithImpl;
@useResult
$Res call({
 String? userId, FeedStatus status, List<FeedPost> posts, FeedCursorEntity? nextCursor, bool isRefreshing, LoadMoreStatus loadMore, Set<String> pendingDeleteIds, int generation, Failure? failure, Failure? refreshFailure
});




}
/// @nodoc
class _$FeedStateCopyWithImpl<$Res>
    implements $FeedStateCopyWith<$Res> {
  _$FeedStateCopyWithImpl(this._self, this._then);

  final FeedState _self;
  final $Res Function(FeedState) _then;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = freezed,Object? status = null,Object? posts = null,Object? nextCursor = freezed,Object? isRefreshing = null,Object? loadMore = null,Object? pendingDeleteIds = null,Object? generation = null,Object? failure = freezed,Object? refreshFailure = freezed,}) {
  return _then(FeedState(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FeedStatus,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<FeedPost>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as FeedCursorEntity?,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,loadMore: null == loadMore ? _self.loadMore : loadMore // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,pendingDeleteIds: null == pendingDeleteIds ? _self.pendingDeleteIds : pendingDeleteIds // ignore: cast_nullable_to_non_nullable
as Set<String>,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,refreshFailure: freezed == refreshFailure ? _self.refreshFailure : refreshFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedState].
extension FeedStatePatterns on FeedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedState value)  $default,){
final _that = this;
switch (_that) {
case _FeedState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedState value)?  $default,){
final _that = this;
switch (_that) {
case _FeedState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? userId,  FeedStatus status,  List<FeedPost> posts,  FeedCursorEntity? nextCursor,  bool isRefreshing,  LoadMoreStatus loadMore,  Set<String> pendingDeleteIds,  int generation,  Failure? failure,  Failure? refreshFailure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedState() when $default != null:
return $default(_that.userId,_that.status,_that.posts,_that.nextCursor,_that.isRefreshing,_that.loadMore,_that.pendingDeleteIds,_that.generation,_that.failure,_that.refreshFailure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? userId,  FeedStatus status,  List<FeedPost> posts,  FeedCursorEntity? nextCursor,  bool isRefreshing,  LoadMoreStatus loadMore,  Set<String> pendingDeleteIds,  int generation,  Failure? failure,  Failure? refreshFailure)  $default,) {final _that = this;
switch (_that) {
case _FeedState():
return $default(_that.userId,_that.status,_that.posts,_that.nextCursor,_that.isRefreshing,_that.loadMore,_that.pendingDeleteIds,_that.generation,_that.failure,_that.refreshFailure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? userId,  FeedStatus status,  List<FeedPost> posts,  FeedCursorEntity? nextCursor,  bool isRefreshing,  LoadMoreStatus loadMore,  Set<String> pendingDeleteIds,  int generation,  Failure? failure,  Failure? refreshFailure)?  $default,) {final _that = this;
switch (_that) {
case _FeedState() when $default != null:
return $default(_that.userId,_that.status,_that.posts,_that.nextCursor,_that.isRefreshing,_that.loadMore,_that.pendingDeleteIds,_that.generation,_that.failure,_that.refreshFailure);case _:
  return null;

}
}

}

/// @nodoc


class _FeedState extends FeedState {
  const _FeedState({this.userId, this.status = FeedStatus.initial,  List<FeedPost> posts = const <FeedPost>[], this.nextCursor, this.isRefreshing = false, this.loadMore = LoadMoreStatus.idle,  Set<String> pendingDeleteIds = const <String>{}, this.generation = 0, this.failure, this.refreshFailure}): _posts = posts,_pendingDeleteIds = pendingDeleteIds,super._();
  

/// The signed-in person, to tell their own posts apart.
@override final  String? userId;
@override@JsonKey() final  FeedStatus status;
 final  List<FeedPost> _posts;
@override@JsonKey() List<FeedPost> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

/// Where the next page starts; null on the last page.
@override final  FeedCursorEntity? nextCursor;
@override@JsonKey() final  bool isRefreshing;
@override@JsonKey() final  LoadMoreStatus loadMore;
/// Posts whose delete can still be undone: they are not shown, and when they were the last ones the
/// empty page shows.
 final  Set<String> _pendingDeleteIds;
/// Posts whose delete can still be undone: they are not shown, and when they were the last ones the
/// empty page shows.
@override@JsonKey() Set<String> get pendingDeleteIds {
  if (_pendingDeleteIds is EqualUnmodifiableSetView) return _pendingDeleteIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_pendingDeleteIds);
}

/// Counts the times the posts were replaced (first load, refresh): what was done to the old ones
/// no longer applies.
@override@JsonKey() final  int generation;
/// Why the first load failed.
@override final  Failure? failure;
/// One-shot: a refresh failed; the posts on screen stay.
@override final  Failure? refreshFailure;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedStateCopyWith<_FeedState> get copyWith => __$FeedStateCopyWithImpl<_FeedState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedState&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.posts, _posts)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.loadMore, loadMore) || other.loadMore == loadMore)&&const DeepCollectionEquality().equals(other.pendingDeleteIds, _pendingDeleteIds)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.refreshFailure, refreshFailure) || other.refreshFailure == refreshFailure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,status,const DeepCollectionEquality().hash(_posts),nextCursor,isRefreshing,loadMore,const DeepCollectionEquality().hash(_pendingDeleteIds),generation,failure,refreshFailure);
}

@override
String toString() {
    return 'FeedState(userId: $userId, status: $status, posts: $posts, nextCursor: $nextCursor, isRefreshing: $isRefreshing, loadMore: $loadMore, pendingDeleteIds: $pendingDeleteIds, generation: $generation, failure: $failure, refreshFailure: $refreshFailure)';
}


}

/// @nodoc
abstract mixin class _$FeedStateCopyWith<$Res> implements $FeedStateCopyWith<$Res> {
  factory _$FeedStateCopyWith(_FeedState value, $Res Function(_FeedState) _then) = __$FeedStateCopyWithImpl;
@override @useResult
$Res call({
 String? userId, FeedStatus status, List<FeedPost> posts, FeedCursorEntity? nextCursor, bool isRefreshing, LoadMoreStatus loadMore, Set<String> pendingDeleteIds, int generation, Failure? failure, Failure? refreshFailure
});




}
/// @nodoc
class __$FeedStateCopyWithImpl<$Res>
    implements _$FeedStateCopyWith<$Res> {
  __$FeedStateCopyWithImpl(this._self, this._then);

  final _FeedState _self;
  final $Res Function(_FeedState) _then;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = freezed,Object? status = null,Object? posts = null,Object? nextCursor = freezed,Object? isRefreshing = null,Object? loadMore = null,Object? pendingDeleteIds = null,Object? generation = null,Object? failure = freezed,Object? refreshFailure = freezed,}) {
  return _then(_FeedState(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FeedStatus,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<FeedPost>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as FeedCursorEntity?,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,loadMore: null == loadMore ? _self.loadMore : loadMore // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,pendingDeleteIds: null == pendingDeleteIds ? _self._pendingDeleteIds : pendingDeleteIds // ignore: cast_nullable_to_non_nullable
as Set<String>,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,refreshFailure: freezed == refreshFailure ? _self.refreshFailure : refreshFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
