// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'security_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SecurityState {

 String get current; String get next; String get confirm; bool get isUpdating; bool get isLoggingOutOthers;/// The current password typed was wrong; shown under that field.
 bool get currentWrong;/// This phone's name; null until read.
 String? get deviceName;/// One-shot: what the screen tells the user.
 SecurityNotice? get notice;/// Why the last action failed; the screen shows it once.
 Failure? get failure;
/// Create a copy of SecurityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SecurityStateCopyWith<SecurityState> get copyWith => _$SecurityStateCopyWithImpl<SecurityState>(this as SecurityState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SecurityState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SecurityState&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.next, _this.next) || other.next == _this.next)&&(identical(other.confirm, _this.confirm) || other.confirm == _this.confirm)&&(identical(other.isUpdating, _this.isUpdating) || other.isUpdating == _this.isUpdating)&&(identical(other.isLoggingOutOthers, _this.isLoggingOutOthers) || other.isLoggingOutOthers == _this.isLoggingOutOthers)&&(identical(other.currentWrong, _this.currentWrong) || other.currentWrong == _this.currentWrong)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.notice, _this.notice) || other.notice == _this.notice)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as SecurityState;
  return Object.hash(runtimeType,_this.current,_this.next,_this.confirm,_this.isUpdating,_this.isLoggingOutOthers,_this.currentWrong,_this.deviceName,_this.notice,_this.failure);
}

@override
String toString() {
  final _this = this as SecurityState;
  return 'SecurityState(current: ${_this.current}, next: ${_this.next}, confirm: ${_this.confirm}, isUpdating: ${_this.isUpdating}, isLoggingOutOthers: ${_this.isLoggingOutOthers}, currentWrong: ${_this.currentWrong}, deviceName: ${_this.deviceName}, notice: ${_this.notice}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $SecurityStateCopyWith<$Res>  {
  factory $SecurityStateCopyWith(SecurityState value, $Res Function(SecurityState) _then) = _$SecurityStateCopyWithImpl;
@useResult
$Res call({
 String current, String next, String confirm, bool isUpdating, bool isLoggingOutOthers, bool currentWrong, String? deviceName, SecurityNotice? notice, Failure? failure
});




}
/// @nodoc
class _$SecurityStateCopyWithImpl<$Res>
    implements $SecurityStateCopyWith<$Res> {
  _$SecurityStateCopyWithImpl(this._self, this._then);

  final SecurityState _self;
  final $Res Function(SecurityState) _then;

/// Create a copy of SecurityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? next = null,Object? confirm = null,Object? isUpdating = null,Object? isLoggingOutOthers = null,Object? currentWrong = null,Object? deviceName = freezed,Object? notice = freezed,Object? failure = freezed,}) {
  return _then(SecurityState(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as String,next: null == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String,confirm: null == confirm ? _self.confirm : confirm // ignore: cast_nullable_to_non_nullable
as String,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,isLoggingOutOthers: null == isLoggingOutOthers ? _self.isLoggingOutOthers : isLoggingOutOthers // ignore: cast_nullable_to_non_nullable
as bool,currentWrong: null == currentWrong ? _self.currentWrong : currentWrong // ignore: cast_nullable_to_non_nullable
as bool,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as SecurityNotice?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [SecurityState].
extension SecurityStatePatterns on SecurityState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SecurityState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SecurityState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SecurityState value)  $default,){
final _that = this;
switch (_that) {
case _SecurityState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SecurityState value)?  $default,){
final _that = this;
switch (_that) {
case _SecurityState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String current,  String next,  String confirm,  bool isUpdating,  bool isLoggingOutOthers,  bool currentWrong,  String? deviceName,  SecurityNotice? notice,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SecurityState() when $default != null:
return $default(_that.current,_that.next,_that.confirm,_that.isUpdating,_that.isLoggingOutOthers,_that.currentWrong,_that.deviceName,_that.notice,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String current,  String next,  String confirm,  bool isUpdating,  bool isLoggingOutOthers,  bool currentWrong,  String? deviceName,  SecurityNotice? notice,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _SecurityState():
return $default(_that.current,_that.next,_that.confirm,_that.isUpdating,_that.isLoggingOutOthers,_that.currentWrong,_that.deviceName,_that.notice,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String current,  String next,  String confirm,  bool isUpdating,  bool isLoggingOutOthers,  bool currentWrong,  String? deviceName,  SecurityNotice? notice,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _SecurityState() when $default != null:
return $default(_that.current,_that.next,_that.confirm,_that.isUpdating,_that.isLoggingOutOthers,_that.currentWrong,_that.deviceName,_that.notice,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _SecurityState extends SecurityState {
  const _SecurityState({this.current = '', this.next = '', this.confirm = '', this.isUpdating = false, this.isLoggingOutOthers = false, this.currentWrong = false, this.deviceName, this.notice, this.failure}): super._();
  

@override@JsonKey() final  String current;
@override@JsonKey() final  String next;
@override@JsonKey() final  String confirm;
@override@JsonKey() final  bool isUpdating;
@override@JsonKey() final  bool isLoggingOutOthers;
/// The current password typed was wrong; shown under that field.
@override@JsonKey() final  bool currentWrong;
/// This phone's name; null until read.
@override final  String? deviceName;
/// One-shot: what the screen tells the user.
@override final  SecurityNotice? notice;
/// Why the last action failed; the screen shows it once.
@override final  Failure? failure;

/// Create a copy of SecurityState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SecurityStateCopyWith<_SecurityState> get copyWith => __$SecurityStateCopyWithImpl<_SecurityState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SecurityState&&(identical(other.current, current) || other.current == current)&&(identical(other.next, next) || other.next == next)&&(identical(other.confirm, confirm) || other.confirm == confirm)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.isLoggingOutOthers, isLoggingOutOthers) || other.isLoggingOutOthers == isLoggingOutOthers)&&(identical(other.currentWrong, currentWrong) || other.currentWrong == currentWrong)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.notice, notice) || other.notice == notice)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,current,next,confirm,isUpdating,isLoggingOutOthers,currentWrong,deviceName,notice,failure);
}

@override
String toString() {
    return 'SecurityState(current: $current, next: $next, confirm: $confirm, isUpdating: $isUpdating, isLoggingOutOthers: $isLoggingOutOthers, currentWrong: $currentWrong, deviceName: $deviceName, notice: $notice, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$SecurityStateCopyWith<$Res> implements $SecurityStateCopyWith<$Res> {
  factory _$SecurityStateCopyWith(_SecurityState value, $Res Function(_SecurityState) _then) = __$SecurityStateCopyWithImpl;
@override @useResult
$Res call({
 String current, String next, String confirm, bool isUpdating, bool isLoggingOutOthers, bool currentWrong, String? deviceName, SecurityNotice? notice, Failure? failure
});




}
/// @nodoc
class __$SecurityStateCopyWithImpl<$Res>
    implements _$SecurityStateCopyWith<$Res> {
  __$SecurityStateCopyWithImpl(this._self, this._then);

  final _SecurityState _self;
  final $Res Function(_SecurityState) _then;

/// Create a copy of SecurityState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? next = null,Object? confirm = null,Object? isUpdating = null,Object? isLoggingOutOthers = null,Object? currentWrong = null,Object? deviceName = freezed,Object? notice = freezed,Object? failure = freezed,}) {
  return _then(_SecurityState(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as String,next: null == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String,confirm: null == confirm ? _self.confirm : confirm // ignore: cast_nullable_to_non_nullable
as String,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,isLoggingOutOthers: null == isLoggingOutOthers ? _self.isLoggingOutOthers : isLoggingOutOthers // ignore: cast_nullable_to_non_nullable
as bool,currentWrong: null == currentWrong ? _self.currentWrong : currentWrong // ignore: cast_nullable_to_non_nullable
as bool,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as SecurityNotice?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
