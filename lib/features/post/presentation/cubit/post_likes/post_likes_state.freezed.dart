// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_likes_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostLikesState {

 PostLikesStatus get status;/// What is typed in the search field; blank shows everyone.
 String get query; List<PostLikerEntity> get likers;/// How many people the signed-in user may see on the post; null until the first page is in.
 int? get total;/// Where the next page starts; null when there is none.
 PostLikersCursorEntity? get nextCursor; LoadMoreStatus get more;/// A pull to refresh is running; the rows stay.
 bool get isRefreshing;/// The signed-in user, who has no Follow button on their own row.
 String? get userId;/// One-shot: a follow or a refresh did not go through (a follow is put back).
 Failure? get failure;
/// Create a copy of PostLikesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostLikesStateCopyWith<PostLikesState> get copyWith => _$PostLikesStateCopyWithImpl<PostLikesState>(this as PostLikesState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PostLikesState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostLikesState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.query, _this.query) || other.query == _this.query)&&const DeepCollectionEquality().equals(other.likers, _this.likers)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor)&&(identical(other.more, _this.more) || other.more == _this.more)&&(identical(other.isRefreshing, _this.isRefreshing) || other.isRefreshing == _this.isRefreshing)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as PostLikesState;
  return Object.hash(runtimeType,_this.status,_this.query,const DeepCollectionEquality().hash(_this.likers),_this.total,_this.nextCursor,_this.more,_this.isRefreshing,_this.userId,_this.failure);
}

@override
String toString() {
  final _this = this as PostLikesState;
  return 'PostLikesState(status: ${_this.status}, query: ${_this.query}, likers: ${_this.likers}, total: ${_this.total}, nextCursor: ${_this.nextCursor}, more: ${_this.more}, isRefreshing: ${_this.isRefreshing}, userId: ${_this.userId}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $PostLikesStateCopyWith<$Res>  {
  factory $PostLikesStateCopyWith(PostLikesState value, $Res Function(PostLikesState) _then) = _$PostLikesStateCopyWithImpl;
@useResult
$Res call({
 PostLikesStatus status, String query, List<PostLikerEntity> likers, int? total, PostLikersCursorEntity? nextCursor, LoadMoreStatus more, bool isRefreshing, String? userId, Failure? failure
});




}
/// @nodoc
class _$PostLikesStateCopyWithImpl<$Res>
    implements $PostLikesStateCopyWith<$Res> {
  _$PostLikesStateCopyWithImpl(this._self, this._then);

  final PostLikesState _self;
  final $Res Function(PostLikesState) _then;

/// Create a copy of PostLikesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? query = null,Object? likers = null,Object? total = freezed,Object? nextCursor = freezed,Object? more = null,Object? isRefreshing = null,Object? userId = freezed,Object? failure = freezed,}) {
  return _then(PostLikesState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostLikesStatus,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,likers: null == likers ? _self.likers : likers // ignore: cast_nullable_to_non_nullable
as List<PostLikerEntity>,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as PostLikersCursorEntity?,more: null == more ? _self.more : more // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostLikesState].
extension PostLikesStatePatterns on PostLikesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostLikesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostLikesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostLikesState value)  $default,){
final _that = this;
switch (_that) {
case _PostLikesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostLikesState value)?  $default,){
final _that = this;
switch (_that) {
case _PostLikesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PostLikesStatus status,  String query,  List<PostLikerEntity> likers,  int? total,  PostLikersCursorEntity? nextCursor,  LoadMoreStatus more,  bool isRefreshing,  String? userId,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostLikesState() when $default != null:
return $default(_that.status,_that.query,_that.likers,_that.total,_that.nextCursor,_that.more,_that.isRefreshing,_that.userId,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PostLikesStatus status,  String query,  List<PostLikerEntity> likers,  int? total,  PostLikersCursorEntity? nextCursor,  LoadMoreStatus more,  bool isRefreshing,  String? userId,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _PostLikesState():
return $default(_that.status,_that.query,_that.likers,_that.total,_that.nextCursor,_that.more,_that.isRefreshing,_that.userId,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PostLikesStatus status,  String query,  List<PostLikerEntity> likers,  int? total,  PostLikersCursorEntity? nextCursor,  LoadMoreStatus more,  bool isRefreshing,  String? userId,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _PostLikesState() when $default != null:
return $default(_that.status,_that.query,_that.likers,_that.total,_that.nextCursor,_that.more,_that.isRefreshing,_that.userId,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _PostLikesState extends PostLikesState {
  const _PostLikesState({this.status = PostLikesStatus.loading, this.query = '',  List<PostLikerEntity> likers = const <PostLikerEntity>[], this.total, this.nextCursor, this.more = LoadMoreStatus.idle, this.isRefreshing = false, this.userId, this.failure}): _likers = likers,super._();
  

@override@JsonKey() final  PostLikesStatus status;
/// What is typed in the search field; blank shows everyone.
@override@JsonKey() final  String query;
 final  List<PostLikerEntity> _likers;
@override@JsonKey() List<PostLikerEntity> get likers {
  if (_likers is EqualUnmodifiableListView) return _likers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likers);
}

/// How many people the signed-in user may see on the post; null until the first page is in.
@override final  int? total;
/// Where the next page starts; null when there is none.
@override final  PostLikersCursorEntity? nextCursor;
@override@JsonKey() final  LoadMoreStatus more;
/// A pull to refresh is running; the rows stay.
@override@JsonKey() final  bool isRefreshing;
/// The signed-in user, who has no Follow button on their own row.
@override final  String? userId;
/// One-shot: a follow or a refresh did not go through (a follow is put back).
@override final  Failure? failure;

/// Create a copy of PostLikesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostLikesStateCopyWith<_PostLikesState> get copyWith => __$PostLikesStateCopyWithImpl<_PostLikesState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostLikesState&&(identical(other.status, status) || other.status == status)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.likers, _likers)&&(identical(other.total, total) || other.total == total)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.more, more) || other.more == more)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,query,const DeepCollectionEquality().hash(_likers),total,nextCursor,more,isRefreshing,userId,failure);
}

@override
String toString() {
    return 'PostLikesState(status: $status, query: $query, likers: $likers, total: $total, nextCursor: $nextCursor, more: $more, isRefreshing: $isRefreshing, userId: $userId, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$PostLikesStateCopyWith<$Res> implements $PostLikesStateCopyWith<$Res> {
  factory _$PostLikesStateCopyWith(_PostLikesState value, $Res Function(_PostLikesState) _then) = __$PostLikesStateCopyWithImpl;
@override @useResult
$Res call({
 PostLikesStatus status, String query, List<PostLikerEntity> likers, int? total, PostLikersCursorEntity? nextCursor, LoadMoreStatus more, bool isRefreshing, String? userId, Failure? failure
});




}
/// @nodoc
class __$PostLikesStateCopyWithImpl<$Res>
    implements _$PostLikesStateCopyWith<$Res> {
  __$PostLikesStateCopyWithImpl(this._self, this._then);

  final _PostLikesState _self;
  final $Res Function(_PostLikesState) _then;

/// Create a copy of PostLikesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? query = null,Object? likers = null,Object? total = freezed,Object? nextCursor = freezed,Object? more = null,Object? isRefreshing = null,Object? userId = freezed,Object? failure = freezed,}) {
  return _then(_PostLikesState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostLikesStatus,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,likers: null == likers ? _self._likers : likers // ignore: cast_nullable_to_non_nullable
as List<PostLikerEntity>,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as PostLikersCursorEntity?,more: null == more ? _self.more : more // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
