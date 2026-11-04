// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'privacy_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrivacyState {

/// The choices; null until they load.
 PrivacySettingsModel? get settings;/// The choices could not be read: the page offers a retry.
 bool get loadFailed;/// How many accounts are blocked; null until known.
 int? get blockedCount;/// Why the last save failed (the choice is back to its old value); the screen shows it once.
 Failure? get failure;
/// Create a copy of PrivacyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivacyStateCopyWith<PrivacyState> get copyWith => _$PrivacyStateCopyWithImpl<PrivacyState>(this as PrivacyState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PrivacyState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivacyState&&(identical(other.settings, _this.settings) || other.settings == _this.settings)&&(identical(other.loadFailed, _this.loadFailed) || other.loadFailed == _this.loadFailed)&&(identical(other.blockedCount, _this.blockedCount) || other.blockedCount == _this.blockedCount)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as PrivacyState;
  return Object.hash(runtimeType,_this.settings,_this.loadFailed,_this.blockedCount,_this.failure);
}

@override
String toString() {
  final _this = this as PrivacyState;
  return 'PrivacyState(settings: ${_this.settings}, loadFailed: ${_this.loadFailed}, blockedCount: ${_this.blockedCount}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $PrivacyStateCopyWith<$Res>  {
  factory $PrivacyStateCopyWith(PrivacyState value, $Res Function(PrivacyState) _then) = _$PrivacyStateCopyWithImpl;
@useResult
$Res call({
 PrivacySettingsModel? settings, bool loadFailed, int? blockedCount, Failure? failure
});




}
/// @nodoc
class _$PrivacyStateCopyWithImpl<$Res>
    implements $PrivacyStateCopyWith<$Res> {
  _$PrivacyStateCopyWithImpl(this._self, this._then);

  final PrivacyState _self;
  final $Res Function(PrivacyState) _then;

/// Create a copy of PrivacyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? settings = freezed,Object? loadFailed = null,Object? blockedCount = freezed,Object? failure = freezed,}) {
  return _then(PrivacyState(
settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as PrivacySettingsModel?,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,blockedCount: freezed == blockedCount ? _self.blockedCount : blockedCount // ignore: cast_nullable_to_non_nullable
as int?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivacyState].
extension PrivacyStatePatterns on PrivacyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivacyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivacyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivacyState value)  $default,){
final _that = this;
switch (_that) {
case _PrivacyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivacyState value)?  $default,){
final _that = this;
switch (_that) {
case _PrivacyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PrivacySettingsModel? settings,  bool loadFailed,  int? blockedCount,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivacyState() when $default != null:
return $default(_that.settings,_that.loadFailed,_that.blockedCount,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PrivacySettingsModel? settings,  bool loadFailed,  int? blockedCount,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _PrivacyState():
return $default(_that.settings,_that.loadFailed,_that.blockedCount,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PrivacySettingsModel? settings,  bool loadFailed,  int? blockedCount,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _PrivacyState() when $default != null:
return $default(_that.settings,_that.loadFailed,_that.blockedCount,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _PrivacyState implements PrivacyState {
  const _PrivacyState({this.settings, this.loadFailed = false, this.blockedCount, this.failure});
  

/// The choices; null until they load.
@override final  PrivacySettingsModel? settings;
/// The choices could not be read: the page offers a retry.
@override@JsonKey() final  bool loadFailed;
/// How many accounts are blocked; null until known.
@override final  int? blockedCount;
/// Why the last save failed (the choice is back to its old value); the screen shows it once.
@override final  Failure? failure;

/// Create a copy of PrivacyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivacyStateCopyWith<_PrivacyState> get copyWith => __$PrivacyStateCopyWithImpl<_PrivacyState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivacyState&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.loadFailed, loadFailed) || other.loadFailed == loadFailed)&&(identical(other.blockedCount, blockedCount) || other.blockedCount == blockedCount)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,settings,loadFailed,blockedCount,failure);
}

@override
String toString() {
    return 'PrivacyState(settings: $settings, loadFailed: $loadFailed, blockedCount: $blockedCount, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$PrivacyStateCopyWith<$Res> implements $PrivacyStateCopyWith<$Res> {
  factory _$PrivacyStateCopyWith(_PrivacyState value, $Res Function(_PrivacyState) _then) = __$PrivacyStateCopyWithImpl;
@override @useResult
$Res call({
 PrivacySettingsModel? settings, bool loadFailed, int? blockedCount, Failure? failure
});




}
/// @nodoc
class __$PrivacyStateCopyWithImpl<$Res>
    implements _$PrivacyStateCopyWith<$Res> {
  __$PrivacyStateCopyWithImpl(this._self, this._then);

  final _PrivacyState _self;
  final $Res Function(_PrivacyState) _then;

/// Create a copy of PrivacyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? settings = freezed,Object? loadFailed = null,Object? blockedCount = freezed,Object? failure = freezed,}) {
  return _then(_PrivacyState(
settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as PrivacySettingsModel?,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,blockedCount: freezed == blockedCount ? _self.blockedCount : blockedCount // ignore: cast_nullable_to_non_nullable
as int?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
