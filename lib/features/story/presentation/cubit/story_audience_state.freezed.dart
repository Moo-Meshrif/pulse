// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_audience_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoryAudienceState {

 StoryAudience get audience;/// The counts under each row; loaded when the sheet opens, again after a list screen.
 AudienceSummaryModel get summary; StoryAudienceStatus get status;/// One-shot: changing the audience failed (it went back to what it was).
 Failure? get failure;
/// Create a copy of StoryAudienceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryAudienceStateCopyWith<StoryAudienceState> get copyWith => _$StoryAudienceStateCopyWithImpl<StoryAudienceState>(this as StoryAudienceState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StoryAudienceState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryAudienceState&&(identical(other.audience, _this.audience) || other.audience == _this.audience)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as StoryAudienceState;
  return Object.hash(runtimeType,_this.audience,_this.summary,_this.status,_this.failure);
}

@override
String toString() {
  final _this = this as StoryAudienceState;
  return 'StoryAudienceState(audience: ${_this.audience}, summary: ${_this.summary}, status: ${_this.status}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $StoryAudienceStateCopyWith<$Res>  {
  factory $StoryAudienceStateCopyWith(StoryAudienceState value, $Res Function(StoryAudienceState) _then) = _$StoryAudienceStateCopyWithImpl;
@useResult
$Res call({
 StoryAudience audience, AudienceSummaryModel summary, StoryAudienceStatus status, Failure? failure
});




}
/// @nodoc
class _$StoryAudienceStateCopyWithImpl<$Res>
    implements $StoryAudienceStateCopyWith<$Res> {
  _$StoryAudienceStateCopyWithImpl(this._self, this._then);

  final StoryAudienceState _self;
  final $Res Function(StoryAudienceState) _then;

/// Create a copy of StoryAudienceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? audience = null,Object? summary = null,Object? status = null,Object? failure = freezed,}) {
  return _then(StoryAudienceState(
audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as StoryAudience,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as AudienceSummaryModel,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StoryAudienceStatus,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryAudienceState].
extension StoryAudienceStatePatterns on StoryAudienceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryAudienceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryAudienceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryAudienceState value)  $default,){
final _that = this;
switch (_that) {
case _StoryAudienceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryAudienceState value)?  $default,){
final _that = this;
switch (_that) {
case _StoryAudienceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StoryAudience audience,  AudienceSummaryModel summary,  StoryAudienceStatus status,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryAudienceState() when $default != null:
return $default(_that.audience,_that.summary,_that.status,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StoryAudience audience,  AudienceSummaryModel summary,  StoryAudienceStatus status,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _StoryAudienceState():
return $default(_that.audience,_that.summary,_that.status,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StoryAudience audience,  AudienceSummaryModel summary,  StoryAudienceStatus status,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _StoryAudienceState() when $default != null:
return $default(_that.audience,_that.summary,_that.status,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _StoryAudienceState implements StoryAudienceState {
  const _StoryAudienceState({required this.audience, this.summary = const AudienceSummaryModel(), this.status = StoryAudienceStatus.loading, this.failure});
  

@override final  StoryAudience audience;
/// The counts under each row; loaded when the sheet opens, again after a list screen.
@override@JsonKey() final  AudienceSummaryModel summary;
@override@JsonKey() final  StoryAudienceStatus status;
/// One-shot: changing the audience failed (it went back to what it was).
@override final  Failure? failure;

/// Create a copy of StoryAudienceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryAudienceStateCopyWith<_StoryAudienceState> get copyWith => __$StoryAudienceStateCopyWithImpl<_StoryAudienceState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryAudienceState&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.status, status) || other.status == status)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,audience,summary,status,failure);
}

@override
String toString() {
    return 'StoryAudienceState(audience: $audience, summary: $summary, status: $status, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$StoryAudienceStateCopyWith<$Res> implements $StoryAudienceStateCopyWith<$Res> {
  factory _$StoryAudienceStateCopyWith(_StoryAudienceState value, $Res Function(_StoryAudienceState) _then) = __$StoryAudienceStateCopyWithImpl;
@override @useResult
$Res call({
 StoryAudience audience, AudienceSummaryModel summary, StoryAudienceStatus status, Failure? failure
});




}
/// @nodoc
class __$StoryAudienceStateCopyWithImpl<$Res>
    implements _$StoryAudienceStateCopyWith<$Res> {
  __$StoryAudienceStateCopyWithImpl(this._self, this._then);

  final _StoryAudienceState _self;
  final $Res Function(_StoryAudienceState) _then;

/// Create a copy of StoryAudienceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? audience = null,Object? summary = null,Object? status = null,Object? failure = freezed,}) {
  return _then(_StoryAudienceState(
audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as StoryAudience,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as AudienceSummaryModel,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StoryAudienceStatus,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
