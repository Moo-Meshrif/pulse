// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tagged_people_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaggedPeopleState {

 TaggedPeopleStatus get status; List<TaggedPersonEntity> get people;/// One-shot: a follow did not go through and was put back.
 Failure? get failure;
/// Create a copy of TaggedPeopleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaggedPeopleStateCopyWith<TaggedPeopleState> get copyWith => _$TaggedPeopleStateCopyWithImpl<TaggedPeopleState>(this as TaggedPeopleState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaggedPeopleState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaggedPeopleState&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.people, _this.people)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as TaggedPeopleState;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.people),_this.failure);
}

@override
String toString() {
  final _this = this as TaggedPeopleState;
  return 'TaggedPeopleState(status: ${_this.status}, people: ${_this.people}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $TaggedPeopleStateCopyWith<$Res>  {
  factory $TaggedPeopleStateCopyWith(TaggedPeopleState value, $Res Function(TaggedPeopleState) _then) = _$TaggedPeopleStateCopyWithImpl;
@useResult
$Res call({
 TaggedPeopleStatus status, List<TaggedPersonEntity> people, Failure? failure
});




}
/// @nodoc
class _$TaggedPeopleStateCopyWithImpl<$Res>
    implements $TaggedPeopleStateCopyWith<$Res> {
  _$TaggedPeopleStateCopyWithImpl(this._self, this._then);

  final TaggedPeopleState _self;
  final $Res Function(TaggedPeopleState) _then;

/// Create a copy of TaggedPeopleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? people = null,Object? failure = freezed,}) {
  return _then(TaggedPeopleState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaggedPeopleStatus,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as List<TaggedPersonEntity>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaggedPeopleState].
extension TaggedPeopleStatePatterns on TaggedPeopleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaggedPeopleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaggedPeopleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaggedPeopleState value)  $default,){
final _that = this;
switch (_that) {
case _TaggedPeopleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaggedPeopleState value)?  $default,){
final _that = this;
switch (_that) {
case _TaggedPeopleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TaggedPeopleStatus status,  List<TaggedPersonEntity> people,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaggedPeopleState() when $default != null:
return $default(_that.status,_that.people,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TaggedPeopleStatus status,  List<TaggedPersonEntity> people,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _TaggedPeopleState():
return $default(_that.status,_that.people,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TaggedPeopleStatus status,  List<TaggedPersonEntity> people,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _TaggedPeopleState() when $default != null:
return $default(_that.status,_that.people,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _TaggedPeopleState implements TaggedPeopleState {
  const _TaggedPeopleState({this.status = TaggedPeopleStatus.loading,  List<TaggedPersonEntity> people = const <TaggedPersonEntity>[], this.failure}): _people = people;
  

@override@JsonKey() final  TaggedPeopleStatus status;
 final  List<TaggedPersonEntity> _people;
@override@JsonKey() List<TaggedPersonEntity> get people {
  if (_people is EqualUnmodifiableListView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_people);
}

/// One-shot: a follow did not go through and was put back.
@override final  Failure? failure;

/// Create a copy of TaggedPeopleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaggedPeopleStateCopyWith<_TaggedPeopleState> get copyWith => __$TaggedPeopleStateCopyWithImpl<_TaggedPeopleState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaggedPeopleState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.people, _people)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_people),failure);
}

@override
String toString() {
    return 'TaggedPeopleState(status: $status, people: $people, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$TaggedPeopleStateCopyWith<$Res> implements $TaggedPeopleStateCopyWith<$Res> {
  factory _$TaggedPeopleStateCopyWith(_TaggedPeopleState value, $Res Function(_TaggedPeopleState) _then) = __$TaggedPeopleStateCopyWithImpl;
@override @useResult
$Res call({
 TaggedPeopleStatus status, List<TaggedPersonEntity> people, Failure? failure
});




}
/// @nodoc
class __$TaggedPeopleStateCopyWithImpl<$Res>
    implements _$TaggedPeopleStateCopyWith<$Res> {
  __$TaggedPeopleStateCopyWithImpl(this._self, this._then);

  final _TaggedPeopleState _self;
  final $Res Function(_TaggedPeopleState) _then;

/// Create a copy of TaggedPeopleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? people = null,Object? failure = freezed,}) {
  return _then(_TaggedPeopleState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaggedPeopleStatus,people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as List<TaggedPersonEntity>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
