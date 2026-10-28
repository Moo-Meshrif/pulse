// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifications_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationsState {

/// The switches; null until they load.
 NotificationPrefsModel? get prefs;/// The switches could not be read: the page offers a retry.
 bool get loadFailed;/// Why the last save failed (the switch is back to its old value); the screen shows it once.
 Failure? get failure;
/// Create a copy of NotificationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationsStateCopyWith<NotificationsState> get copyWith => _$NotificationsStateCopyWithImpl<NotificationsState>(this as NotificationsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NotificationsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationsState&&(identical(other.prefs, _this.prefs) || other.prefs == _this.prefs)&&(identical(other.loadFailed, _this.loadFailed) || other.loadFailed == _this.loadFailed)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as NotificationsState;
  return Object.hash(runtimeType,_this.prefs,_this.loadFailed,_this.failure);
}

@override
String toString() {
  final _this = this as NotificationsState;
  return 'NotificationsState(prefs: ${_this.prefs}, loadFailed: ${_this.loadFailed}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $NotificationsStateCopyWith<$Res>  {
  factory $NotificationsStateCopyWith(NotificationsState value, $Res Function(NotificationsState) _then) = _$NotificationsStateCopyWithImpl;
@useResult
$Res call({
 NotificationPrefsModel? prefs, bool loadFailed, Failure? failure
});




}
/// @nodoc
class _$NotificationsStateCopyWithImpl<$Res>
    implements $NotificationsStateCopyWith<$Res> {
  _$NotificationsStateCopyWithImpl(this._self, this._then);

  final NotificationsState _self;
  final $Res Function(NotificationsState) _then;

/// Create a copy of NotificationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prefs = freezed,Object? loadFailed = null,Object? failure = freezed,}) {
  return _then(NotificationsState(
prefs: freezed == prefs ? _self.prefs : prefs // ignore: cast_nullable_to_non_nullable
as NotificationPrefsModel?,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationsState].
extension NotificationsStatePatterns on NotificationsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationsState value)  $default,){
final _that = this;
switch (_that) {
case _NotificationsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationsState value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NotificationPrefsModel? prefs,  bool loadFailed,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationsState() when $default != null:
return $default(_that.prefs,_that.loadFailed,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NotificationPrefsModel? prefs,  bool loadFailed,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _NotificationsState():
return $default(_that.prefs,_that.loadFailed,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NotificationPrefsModel? prefs,  bool loadFailed,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _NotificationsState() when $default != null:
return $default(_that.prefs,_that.loadFailed,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationsState implements NotificationsState {
  const _NotificationsState({this.prefs, this.loadFailed = false, this.failure});
  

/// The switches; null until they load.
@override final  NotificationPrefsModel? prefs;
/// The switches could not be read: the page offers a retry.
@override@JsonKey() final  bool loadFailed;
/// Why the last save failed (the switch is back to its old value); the screen shows it once.
@override final  Failure? failure;

/// Create a copy of NotificationsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationsStateCopyWith<_NotificationsState> get copyWith => __$NotificationsStateCopyWithImpl<_NotificationsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationsState&&(identical(other.prefs, prefs) || other.prefs == prefs)&&(identical(other.loadFailed, loadFailed) || other.loadFailed == loadFailed)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,prefs,loadFailed,failure);
}

@override
String toString() {
    return 'NotificationsState(prefs: $prefs, loadFailed: $loadFailed, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$NotificationsStateCopyWith<$Res> implements $NotificationsStateCopyWith<$Res> {
  factory _$NotificationsStateCopyWith(_NotificationsState value, $Res Function(_NotificationsState) _then) = __$NotificationsStateCopyWithImpl;
@override @useResult
$Res call({
 NotificationPrefsModel? prefs, bool loadFailed, Failure? failure
});




}
/// @nodoc
class __$NotificationsStateCopyWithImpl<$Res>
    implements _$NotificationsStateCopyWith<$Res> {
  __$NotificationsStateCopyWithImpl(this._self, this._then);

  final _NotificationsState _self;
  final $Res Function(_NotificationsState) _then;

/// Create a copy of NotificationsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prefs = freezed,Object? loadFailed = null,Object? failure = freezed,}) {
  return _then(_NotificationsState(
prefs: freezed == prefs ? _self.prefs : prefs // ignore: cast_nullable_to_non_nullable
as NotificationPrefsModel?,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
