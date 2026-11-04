// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

/// The values beside the rows; null until they arrive (the rows show no value) or when they fail.
 SettingsSummaryModel? get summary;/// The app version, e.g. `1.2.0`; null until read.
 String? get version; bool get autoplayShorts; bool get dataSaver; bool get isLoggingOut; bool get isDeleting;/// The password typed to delete the account was wrong; the dialog shows it under the field.
 bool get passwordWrong;/// This device's session is gone and local data is cleared: the screen leaves to Sign in.
 bool get signedOut;/// Why the last log out or delete failed; the screen shows it once.
 Failure? get failure;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SettingsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.autoplayShorts, _this.autoplayShorts) || other.autoplayShorts == _this.autoplayShorts)&&(identical(other.dataSaver, _this.dataSaver) || other.dataSaver == _this.dataSaver)&&(identical(other.isLoggingOut, _this.isLoggingOut) || other.isLoggingOut == _this.isLoggingOut)&&(identical(other.isDeleting, _this.isDeleting) || other.isDeleting == _this.isDeleting)&&(identical(other.passwordWrong, _this.passwordWrong) || other.passwordWrong == _this.passwordWrong)&&(identical(other.signedOut, _this.signedOut) || other.signedOut == _this.signedOut)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as SettingsState;
  return Object.hash(runtimeType,_this.summary,_this.version,_this.autoplayShorts,_this.dataSaver,_this.isLoggingOut,_this.isDeleting,_this.passwordWrong,_this.signedOut,_this.failure);
}

@override
String toString() {
  final _this = this as SettingsState;
  return 'SettingsState(summary: ${_this.summary}, version: ${_this.version}, autoplayShorts: ${_this.autoplayShorts}, dataSaver: ${_this.dataSaver}, isLoggingOut: ${_this.isLoggingOut}, isDeleting: ${_this.isDeleting}, passwordWrong: ${_this.passwordWrong}, signedOut: ${_this.signedOut}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 SettingsSummaryModel? summary, String? version, bool autoplayShorts, bool dataSaver, bool isLoggingOut, bool isDeleting, bool passwordWrong, bool signedOut, Failure? failure
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = freezed,Object? version = freezed,Object? autoplayShorts = null,Object? dataSaver = null,Object? isLoggingOut = null,Object? isDeleting = null,Object? passwordWrong = null,Object? signedOut = null,Object? failure = freezed,}) {
  return _then(SettingsState(
summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as SettingsSummaryModel?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,autoplayShorts: null == autoplayShorts ? _self.autoplayShorts : autoplayShorts // ignore: cast_nullable_to_non_nullable
as bool,dataSaver: null == dataSaver ? _self.dataSaver : dataSaver // ignore: cast_nullable_to_non_nullable
as bool,isLoggingOut: null == isLoggingOut ? _self.isLoggingOut : isLoggingOut // ignore: cast_nullable_to_non_nullable
as bool,isDeleting: null == isDeleting ? _self.isDeleting : isDeleting // ignore: cast_nullable_to_non_nullable
as bool,passwordWrong: null == passwordWrong ? _self.passwordWrong : passwordWrong // ignore: cast_nullable_to_non_nullable
as bool,signedOut: null == signedOut ? _self.signedOut : signedOut // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SettingsSummaryModel? summary,  String? version,  bool autoplayShorts,  bool dataSaver,  bool isLoggingOut,  bool isDeleting,  bool passwordWrong,  bool signedOut,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.summary,_that.version,_that.autoplayShorts,_that.dataSaver,_that.isLoggingOut,_that.isDeleting,_that.passwordWrong,_that.signedOut,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SettingsSummaryModel? summary,  String? version,  bool autoplayShorts,  bool dataSaver,  bool isLoggingOut,  bool isDeleting,  bool passwordWrong,  bool signedOut,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.summary,_that.version,_that.autoplayShorts,_that.dataSaver,_that.isLoggingOut,_that.isDeleting,_that.passwordWrong,_that.signedOut,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SettingsSummaryModel? summary,  String? version,  bool autoplayShorts,  bool dataSaver,  bool isLoggingOut,  bool isDeleting,  bool passwordWrong,  bool signedOut,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.summary,_that.version,_that.autoplayShorts,_that.dataSaver,_that.isLoggingOut,_that.isDeleting,_that.passwordWrong,_that.signedOut,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({this.summary, this.version, this.autoplayShorts = true, this.dataSaver = false, this.isLoggingOut = false, this.isDeleting = false, this.passwordWrong = false, this.signedOut = false, this.failure});
  

/// The values beside the rows; null until they arrive (the rows show no value) or when they fail.
@override final  SettingsSummaryModel? summary;
/// The app version, e.g. `1.2.0`; null until read.
@override final  String? version;
@override@JsonKey() final  bool autoplayShorts;
@override@JsonKey() final  bool dataSaver;
@override@JsonKey() final  bool isLoggingOut;
@override@JsonKey() final  bool isDeleting;
/// The password typed to delete the account was wrong; the dialog shows it under the field.
@override@JsonKey() final  bool passwordWrong;
/// This device's session is gone and local data is cleared: the screen leaves to Sign in.
@override@JsonKey() final  bool signedOut;
/// Why the last log out or delete failed; the screen shows it once.
@override final  Failure? failure;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.version, version) || other.version == version)&&(identical(other.autoplayShorts, autoplayShorts) || other.autoplayShorts == autoplayShorts)&&(identical(other.dataSaver, dataSaver) || other.dataSaver == dataSaver)&&(identical(other.isLoggingOut, isLoggingOut) || other.isLoggingOut == isLoggingOut)&&(identical(other.isDeleting, isDeleting) || other.isDeleting == isDeleting)&&(identical(other.passwordWrong, passwordWrong) || other.passwordWrong == passwordWrong)&&(identical(other.signedOut, signedOut) || other.signedOut == signedOut)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,summary,version,autoplayShorts,dataSaver,isLoggingOut,isDeleting,passwordWrong,signedOut,failure);
}

@override
String toString() {
    return 'SettingsState(summary: $summary, version: $version, autoplayShorts: $autoplayShorts, dataSaver: $dataSaver, isLoggingOut: $isLoggingOut, isDeleting: $isDeleting, passwordWrong: $passwordWrong, signedOut: $signedOut, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 SettingsSummaryModel? summary, String? version, bool autoplayShorts, bool dataSaver, bool isLoggingOut, bool isDeleting, bool passwordWrong, bool signedOut, Failure? failure
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = freezed,Object? version = freezed,Object? autoplayShorts = null,Object? dataSaver = null,Object? isLoggingOut = null,Object? isDeleting = null,Object? passwordWrong = null,Object? signedOut = null,Object? failure = freezed,}) {
  return _then(_SettingsState(
summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as SettingsSummaryModel?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,autoplayShorts: null == autoplayShorts ? _self.autoplayShorts : autoplayShorts // ignore: cast_nullable_to_non_nullable
as bool,dataSaver: null == dataSaver ? _self.dataSaver : dataSaver // ignore: cast_nullable_to_non_nullable
as bool,isLoggingOut: null == isLoggingOut ? _self.isLoggingOut : isLoggingOut // ignore: cast_nullable_to_non_nullable
as bool,isDeleting: null == isDeleting ? _self.isDeleting : isDeleting // ignore: cast_nullable_to_non_nullable
as bool,passwordWrong: null == passwordWrong ? _self.passwordWrong : passwordWrong // ignore: cast_nullable_to_non_nullable
as bool,signedOut: null == signedOut ? _self.signedOut : signedOut // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
