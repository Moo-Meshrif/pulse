// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_actions_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostActionsState {

/// The post as changed by like, save, comments or audience; missing while nothing changed.
 Map<String, PostEntity> get posts;/// A post's row; missing means [PostRow.card].
 Map<String, PostRow> get rows;/// One-shot: a like or save did not go through and was rolled back.
 Failure? get failure;
/// Create a copy of PostActionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostActionsStateCopyWith<PostActionsState> get copyWith => _$PostActionsStateCopyWithImpl<PostActionsState>(this as PostActionsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PostActionsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostActionsState&&const DeepCollectionEquality().equals(other.posts, _this.posts)&&const DeepCollectionEquality().equals(other.rows, _this.rows)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as PostActionsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.posts),const DeepCollectionEquality().hash(_this.rows),_this.failure);
}

@override
String toString() {
  final _this = this as PostActionsState;
  return 'PostActionsState(posts: ${_this.posts}, rows: ${_this.rows}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $PostActionsStateCopyWith<$Res>  {
  factory $PostActionsStateCopyWith(PostActionsState value, $Res Function(PostActionsState) _then) = _$PostActionsStateCopyWithImpl;
@useResult
$Res call({
 Map<String, PostEntity> posts, Map<String, PostRow> rows, Failure? failure
});




}
/// @nodoc
class _$PostActionsStateCopyWithImpl<$Res>
    implements $PostActionsStateCopyWith<$Res> {
  _$PostActionsStateCopyWithImpl(this._self, this._then);

  final PostActionsState _self;
  final $Res Function(PostActionsState) _then;

/// Create a copy of PostActionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? posts = null,Object? rows = null,Object? failure = freezed,}) {
  return _then(PostActionsState(
posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as Map<String, PostEntity>,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as Map<String, PostRow>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostActionsState].
extension PostActionsStatePatterns on PostActionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostActionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostActionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostActionsState value)  $default,){
final _that = this;
switch (_that) {
case _PostActionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostActionsState value)?  $default,){
final _that = this;
switch (_that) {
case _PostActionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, PostEntity> posts,  Map<String, PostRow> rows,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostActionsState() when $default != null:
return $default(_that.posts,_that.rows,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, PostEntity> posts,  Map<String, PostRow> rows,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _PostActionsState():
return $default(_that.posts,_that.rows,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, PostEntity> posts,  Map<String, PostRow> rows,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _PostActionsState() when $default != null:
return $default(_that.posts,_that.rows,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _PostActionsState implements PostActionsState {
  const _PostActionsState({ Map<String, PostEntity> posts = const <String, PostEntity>{},  Map<String, PostRow> rows = const <String, PostRow>{}, this.failure}): _posts = posts,_rows = rows;
  

/// The post as changed by like, save, comments or audience; missing while nothing changed.
 final  Map<String, PostEntity> _posts;
/// The post as changed by like, save, comments or audience; missing while nothing changed.
@override@JsonKey() Map<String, PostEntity> get posts {
  if (_posts is EqualUnmodifiableMapView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_posts);
}

/// A post's row; missing means [PostRow.card].
 final  Map<String, PostRow> _rows;
/// A post's row; missing means [PostRow.card].
@override@JsonKey() Map<String, PostRow> get rows {
  if (_rows is EqualUnmodifiableMapView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rows);
}

/// One-shot: a like or save did not go through and was rolled back.
@override final  Failure? failure;

/// Create a copy of PostActionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostActionsStateCopyWith<_PostActionsState> get copyWith => __$PostActionsStateCopyWithImpl<_PostActionsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostActionsState&&const DeepCollectionEquality().equals(other.posts, _posts)&&const DeepCollectionEquality().equals(other.rows, _rows)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_posts),const DeepCollectionEquality().hash(_rows),failure);
}

@override
String toString() {
    return 'PostActionsState(posts: $posts, rows: $rows, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$PostActionsStateCopyWith<$Res> implements $PostActionsStateCopyWith<$Res> {
  factory _$PostActionsStateCopyWith(_PostActionsState value, $Res Function(_PostActionsState) _then) = __$PostActionsStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, PostEntity> posts, Map<String, PostRow> rows, Failure? failure
});




}
/// @nodoc
class __$PostActionsStateCopyWithImpl<$Res>
    implements _$PostActionsStateCopyWith<$Res> {
  __$PostActionsStateCopyWithImpl(this._self, this._then);

  final _PostActionsState _self;
  final $Res Function(_PostActionsState) _then;

/// Create a copy of PostActionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? posts = null,Object? rows = null,Object? failure = freezed,}) {
  return _then(_PostActionsState(
posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as Map<String, PostEntity>,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as Map<String, PostRow>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
