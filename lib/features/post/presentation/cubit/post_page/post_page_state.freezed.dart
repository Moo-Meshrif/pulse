// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostPageState {

 PostPageStatus get status;/// The post with its media links signed; the one passed in until the fresh one arrives.
 FeedPost? get post;/// Where your follow of the author stands; null while unknown or on your own post.
 FollowStatus? get follow;/// The "Liked by" row; null when nobody else liked the post or it is not read yet.
 LikedByPreviewEntity? get likedBy;/// The signed-in user, so the post reads "You" and has no Follow chip.
 String? get userId;/// One-shot: a refresh or a follow did not go through.
 Failure? get failure;
/// Create a copy of PostPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostPageStateCopyWith<PostPageState> get copyWith => _$PostPageStateCopyWithImpl<PostPageState>(this as PostPageState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PostPageState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostPageState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.post, _this.post) || other.post == _this.post)&&(identical(other.follow, _this.follow) || other.follow == _this.follow)&&(identical(other.likedBy, _this.likedBy) || other.likedBy == _this.likedBy)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as PostPageState;
  return Object.hash(runtimeType,_this.status,_this.post,_this.follow,_this.likedBy,_this.userId,_this.failure);
}

@override
String toString() {
  final _this = this as PostPageState;
  return 'PostPageState(status: ${_this.status}, post: ${_this.post}, follow: ${_this.follow}, likedBy: ${_this.likedBy}, userId: ${_this.userId}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $PostPageStateCopyWith<$Res>  {
  factory $PostPageStateCopyWith(PostPageState value, $Res Function(PostPageState) _then) = _$PostPageStateCopyWithImpl;
@useResult
$Res call({
 PostPageStatus status, FeedPost? post, FollowStatus? follow, LikedByPreviewEntity? likedBy, String? userId, Failure? failure
});




}
/// @nodoc
class _$PostPageStateCopyWithImpl<$Res>
    implements $PostPageStateCopyWith<$Res> {
  _$PostPageStateCopyWithImpl(this._self, this._then);

  final PostPageState _self;
  final $Res Function(PostPageState) _then;

/// Create a copy of PostPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? post = freezed,Object? follow = freezed,Object? likedBy = freezed,Object? userId = freezed,Object? failure = freezed,}) {
  return _then(PostPageState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostPageStatus,post: freezed == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as FeedPost?,follow: freezed == follow ? _self.follow : follow // ignore: cast_nullable_to_non_nullable
as FollowStatus?,likedBy: freezed == likedBy ? _self.likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as LikedByPreviewEntity?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostPageState].
extension PostPageStatePatterns on PostPageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostPageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostPageState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostPageState value)  $default,){
final _that = this;
switch (_that) {
case _PostPageState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostPageState value)?  $default,){
final _that = this;
switch (_that) {
case _PostPageState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PostPageStatus status,  FeedPost? post,  FollowStatus? follow,  LikedByPreviewEntity? likedBy,  String? userId,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostPageState() when $default != null:
return $default(_that.status,_that.post,_that.follow,_that.likedBy,_that.userId,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PostPageStatus status,  FeedPost? post,  FollowStatus? follow,  LikedByPreviewEntity? likedBy,  String? userId,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _PostPageState():
return $default(_that.status,_that.post,_that.follow,_that.likedBy,_that.userId,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PostPageStatus status,  FeedPost? post,  FollowStatus? follow,  LikedByPreviewEntity? likedBy,  String? userId,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _PostPageState() when $default != null:
return $default(_that.status,_that.post,_that.follow,_that.likedBy,_that.userId,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _PostPageState implements PostPageState {
  const _PostPageState({this.status = PostPageStatus.loading, this.post, this.follow, this.likedBy, this.userId, this.failure});
  

@override@JsonKey() final  PostPageStatus status;
/// The post with its media links signed; the one passed in until the fresh one arrives.
@override final  FeedPost? post;
/// Where your follow of the author stands; null while unknown or on your own post.
@override final  FollowStatus? follow;
/// The "Liked by" row; null when nobody else liked the post or it is not read yet.
@override final  LikedByPreviewEntity? likedBy;
/// The signed-in user, so the post reads "You" and has no Follow chip.
@override final  String? userId;
/// One-shot: a refresh or a follow did not go through.
@override final  Failure? failure;

/// Create a copy of PostPageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostPageStateCopyWith<_PostPageState> get copyWith => __$PostPageStateCopyWithImpl<_PostPageState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostPageState&&(identical(other.status, status) || other.status == status)&&(identical(other.post, post) || other.post == post)&&(identical(other.follow, follow) || other.follow == follow)&&(identical(other.likedBy, likedBy) || other.likedBy == likedBy)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,post,follow,likedBy,userId,failure);
}

@override
String toString() {
    return 'PostPageState(status: $status, post: $post, follow: $follow, likedBy: $likedBy, userId: $userId, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$PostPageStateCopyWith<$Res> implements $PostPageStateCopyWith<$Res> {
  factory _$PostPageStateCopyWith(_PostPageState value, $Res Function(_PostPageState) _then) = __$PostPageStateCopyWithImpl;
@override @useResult
$Res call({
 PostPageStatus status, FeedPost? post, FollowStatus? follow, LikedByPreviewEntity? likedBy, String? userId, Failure? failure
});




}
/// @nodoc
class __$PostPageStateCopyWithImpl<$Res>
    implements _$PostPageStateCopyWith<$Res> {
  __$PostPageStateCopyWithImpl(this._self, this._then);

  final _PostPageState _self;
  final $Res Function(_PostPageState) _then;

/// Create a copy of PostPageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? post = freezed,Object? follow = freezed,Object? likedBy = freezed,Object? userId = freezed,Object? failure = freezed,}) {
  return _then(_PostPageState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostPageStatus,post: freezed == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as FeedPost?,follow: freezed == follow ? _self.follow : follow // ignore: cast_nullable_to_non_nullable
as FollowStatus?,likedBy: freezed == likedBy ? _self.likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as LikedByPreviewEntity?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
