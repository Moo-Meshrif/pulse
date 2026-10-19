// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_visibility_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostVisibilityState {

/// The choice on screen.
 ContentAudience get audience;/// What the post has now ("Currently: Followers"); the choice the sheet opened with.
 ContentAudience get current; PostVisibilityStatus get status; bool get isPrivate; AudienceSummaryEntity get summary;/// "Use for future posts" (New post only).
 bool get saveAsDefault; bool get isSaving;/// One-shot: confirmed; the sheet closes with this.
 PostVisibilityResult? get result;/// One-shot: saving failed; the sheet stays open.
 Failure? get failure;
/// Create a copy of PostVisibilityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostVisibilityStateCopyWith<PostVisibilityState> get copyWith => _$PostVisibilityStateCopyWithImpl<PostVisibilityState>(this as PostVisibilityState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PostVisibilityState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostVisibilityState&&(identical(other.audience, _this.audience) || other.audience == _this.audience)&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.isPrivate, _this.isPrivate) || other.isPrivate == _this.isPrivate)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.saveAsDefault, _this.saveAsDefault) || other.saveAsDefault == _this.saveAsDefault)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as PostVisibilityState;
  return Object.hash(runtimeType,_this.audience,_this.current,_this.status,_this.isPrivate,_this.summary,_this.saveAsDefault,_this.isSaving,_this.result,_this.failure);
}

@override
String toString() {
  final _this = this as PostVisibilityState;
  return 'PostVisibilityState(audience: ${_this.audience}, current: ${_this.current}, status: ${_this.status}, isPrivate: ${_this.isPrivate}, summary: ${_this.summary}, saveAsDefault: ${_this.saveAsDefault}, isSaving: ${_this.isSaving}, result: ${_this.result}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $PostVisibilityStateCopyWith<$Res>  {
  factory $PostVisibilityStateCopyWith(PostVisibilityState value, $Res Function(PostVisibilityState) _then) = _$PostVisibilityStateCopyWithImpl;
@useResult
$Res call({
 ContentAudience audience, ContentAudience current, PostVisibilityStatus status, bool isPrivate, AudienceSummaryEntity summary, bool saveAsDefault, bool isSaving, PostVisibilityResult? result, Failure? failure
});




}
/// @nodoc
class _$PostVisibilityStateCopyWithImpl<$Res>
    implements $PostVisibilityStateCopyWith<$Res> {
  _$PostVisibilityStateCopyWithImpl(this._self, this._then);

  final PostVisibilityState _self;
  final $Res Function(PostVisibilityState) _then;

/// Create a copy of PostVisibilityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? audience = null,Object? current = null,Object? status = null,Object? isPrivate = null,Object? summary = null,Object? saveAsDefault = null,Object? isSaving = null,Object? result = freezed,Object? failure = freezed,}) {
  return _then(PostVisibilityState(
audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as ContentAudience,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as ContentAudience,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostVisibilityStatus,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as AudienceSummaryEntity,saveAsDefault: null == saveAsDefault ? _self.saveAsDefault : saveAsDefault // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as PostVisibilityResult?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostVisibilityState].
extension PostVisibilityStatePatterns on PostVisibilityState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostVisibilityState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostVisibilityState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostVisibilityState value)  $default,){
final _that = this;
switch (_that) {
case _PostVisibilityState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostVisibilityState value)?  $default,){
final _that = this;
switch (_that) {
case _PostVisibilityState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContentAudience audience,  ContentAudience current,  PostVisibilityStatus status,  bool isPrivate,  AudienceSummaryEntity summary,  bool saveAsDefault,  bool isSaving,  PostVisibilityResult? result,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostVisibilityState() when $default != null:
return $default(_that.audience,_that.current,_that.status,_that.isPrivate,_that.summary,_that.saveAsDefault,_that.isSaving,_that.result,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContentAudience audience,  ContentAudience current,  PostVisibilityStatus status,  bool isPrivate,  AudienceSummaryEntity summary,  bool saveAsDefault,  bool isSaving,  PostVisibilityResult? result,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _PostVisibilityState():
return $default(_that.audience,_that.current,_that.status,_that.isPrivate,_that.summary,_that.saveAsDefault,_that.isSaving,_that.result,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContentAudience audience,  ContentAudience current,  PostVisibilityStatus status,  bool isPrivate,  AudienceSummaryEntity summary,  bool saveAsDefault,  bool isSaving,  PostVisibilityResult? result,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _PostVisibilityState() when $default != null:
return $default(_that.audience,_that.current,_that.status,_that.isPrivate,_that.summary,_that.saveAsDefault,_that.isSaving,_that.result,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _PostVisibilityState implements PostVisibilityState {
  const _PostVisibilityState({required this.audience, required this.current, this.status = PostVisibilityStatus.loading, this.isPrivate = false, this.summary = const AudienceSummaryEntity(), this.saveAsDefault = false, this.isSaving = false, this.result, this.failure});
  

/// The choice on screen.
@override final  ContentAudience audience;
/// What the post has now ("Currently: Followers"); the choice the sheet opened with.
@override final  ContentAudience current;
@override@JsonKey() final  PostVisibilityStatus status;
@override@JsonKey() final  bool isPrivate;
@override@JsonKey() final  AudienceSummaryEntity summary;
/// "Use for future posts" (New post only).
@override@JsonKey() final  bool saveAsDefault;
@override@JsonKey() final  bool isSaving;
/// One-shot: confirmed; the sheet closes with this.
@override final  PostVisibilityResult? result;
/// One-shot: saving failed; the sheet stays open.
@override final  Failure? failure;

/// Create a copy of PostVisibilityState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostVisibilityStateCopyWith<_PostVisibilityState> get copyWith => __$PostVisibilityStateCopyWithImpl<_PostVisibilityState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostVisibilityState&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.current, current) || other.current == current)&&(identical(other.status, status) || other.status == status)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.saveAsDefault, saveAsDefault) || other.saveAsDefault == saveAsDefault)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.result, result) || other.result == result)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,audience,current,status,isPrivate,summary,saveAsDefault,isSaving,result,failure);
}

@override
String toString() {
    return 'PostVisibilityState(audience: $audience, current: $current, status: $status, isPrivate: $isPrivate, summary: $summary, saveAsDefault: $saveAsDefault, isSaving: $isSaving, result: $result, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$PostVisibilityStateCopyWith<$Res> implements $PostVisibilityStateCopyWith<$Res> {
  factory _$PostVisibilityStateCopyWith(_PostVisibilityState value, $Res Function(_PostVisibilityState) _then) = __$PostVisibilityStateCopyWithImpl;
@override @useResult
$Res call({
 ContentAudience audience, ContentAudience current, PostVisibilityStatus status, bool isPrivate, AudienceSummaryEntity summary, bool saveAsDefault, bool isSaving, PostVisibilityResult? result, Failure? failure
});




}
/// @nodoc
class __$PostVisibilityStateCopyWithImpl<$Res>
    implements _$PostVisibilityStateCopyWith<$Res> {
  __$PostVisibilityStateCopyWithImpl(this._self, this._then);

  final _PostVisibilityState _self;
  final $Res Function(_PostVisibilityState) _then;

/// Create a copy of PostVisibilityState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? audience = null,Object? current = null,Object? status = null,Object? isPrivate = null,Object? summary = null,Object? saveAsDefault = null,Object? isSaving = null,Object? result = freezed,Object? failure = freezed,}) {
  return _then(_PostVisibilityState(
audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as ContentAudience,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as ContentAudience,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostVisibilityStatus,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as AudienceSummaryEntity,saveAsDefault: null == saveAsDefault ? _self.saveAsDefault : saveAsDefault // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as PostVisibilityResult?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
