// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'legal_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LegalState {

 bool get loading; LegalDocumentModel? get document;/// Why the load failed; the page shows it with a Retry.
 Failure? get failure;
/// Create a copy of LegalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LegalStateCopyWith<LegalState> get copyWith => _$LegalStateCopyWithImpl<LegalState>(this as LegalState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LegalState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LegalState&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.document, _this.document) || other.document == _this.document)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as LegalState;
  return Object.hash(runtimeType,_this.loading,_this.document,_this.failure);
}

@override
String toString() {
  final _this = this as LegalState;
  return 'LegalState(loading: ${_this.loading}, document: ${_this.document}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $LegalStateCopyWith<$Res>  {
  factory $LegalStateCopyWith(LegalState value, $Res Function(LegalState) _then) = _$LegalStateCopyWithImpl;
@useResult
$Res call({
 bool loading, LegalDocumentModel? document, Failure? failure
});




}
/// @nodoc
class _$LegalStateCopyWithImpl<$Res>
    implements $LegalStateCopyWith<$Res> {
  _$LegalStateCopyWithImpl(this._self, this._then);

  final LegalState _self;
  final $Res Function(LegalState) _then;

/// Create a copy of LegalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? document = freezed,Object? failure = freezed,}) {
  return _then(LegalState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as LegalDocumentModel?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [LegalState].
extension LegalStatePatterns on LegalState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LegalState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LegalState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LegalState value)  $default,){
final _that = this;
switch (_that) {
case _LegalState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LegalState value)?  $default,){
final _that = this;
switch (_that) {
case _LegalState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  LegalDocumentModel? document,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LegalState() when $default != null:
return $default(_that.loading,_that.document,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  LegalDocumentModel? document,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _LegalState():
return $default(_that.loading,_that.document,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  LegalDocumentModel? document,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _LegalState() when $default != null:
return $default(_that.loading,_that.document,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _LegalState implements LegalState {
  const _LegalState({this.loading = true, this.document, this.failure});
  

@override@JsonKey() final  bool loading;
@override final  LegalDocumentModel? document;
/// Why the load failed; the page shows it with a Retry.
@override final  Failure? failure;

/// Create a copy of LegalState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LegalStateCopyWith<_LegalState> get copyWith => __$LegalStateCopyWithImpl<_LegalState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LegalState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.document, document) || other.document == document)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,loading,document,failure);
}

@override
String toString() {
    return 'LegalState(loading: $loading, document: $document, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$LegalStateCopyWith<$Res> implements $LegalStateCopyWith<$Res> {
  factory _$LegalStateCopyWith(_LegalState value, $Res Function(_LegalState) _then) = __$LegalStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, LegalDocumentModel? document, Failure? failure
});




}
/// @nodoc
class __$LegalStateCopyWithImpl<$Res>
    implements _$LegalStateCopyWith<$Res> {
  __$LegalStateCopyWithImpl(this._self, this._then);

  final _LegalState _self;
  final $Res Function(_LegalState) _then;

/// Create a copy of LegalState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? document = freezed,Object? failure = freezed,}) {
  return _then(_LegalState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as LegalDocumentModel?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
