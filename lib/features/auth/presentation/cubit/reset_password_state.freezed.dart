// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reset_password_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResetPasswordState {

/// The recovery session's email; null when no recovery session exists (the link expired).
 String? get email; String get password; String get confirm; bool get logoutOthers; bool get loading; Failure? get failure;/// The password was changed; the screen shows the "Password updated" dialog.
 bool get updated;/// With [updated]: the other devices were signed out too (the body of the dialog says so).
 bool get othersLoggedOut;/// One-shot: where the screen goes next (Sign in).
 String? get route;
/// Create a copy of ResetPasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResetPasswordStateCopyWith<ResetPasswordState> get copyWith => _$ResetPasswordStateCopyWithImpl<ResetPasswordState>(this as ResetPasswordState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ResetPasswordState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetPasswordState&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.confirm, _this.confirm) || other.confirm == _this.confirm)&&(identical(other.logoutOthers, _this.logoutOthers) || other.logoutOthers == _this.logoutOthers)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.updated, _this.updated) || other.updated == _this.updated)&&(identical(other.othersLoggedOut, _this.othersLoggedOut) || other.othersLoggedOut == _this.othersLoggedOut)&&(identical(other.route, _this.route) || other.route == _this.route));
}


@override
int get hashCode {
  final _this = this as ResetPasswordState;
  return Object.hash(runtimeType,_this.email,_this.password,_this.confirm,_this.logoutOthers,_this.loading,_this.failure,_this.updated,_this.othersLoggedOut,_this.route);
}

@override
String toString() {
  final _this = this as ResetPasswordState;
  return 'ResetPasswordState(email: ${_this.email}, password: ${_this.password}, confirm: ${_this.confirm}, logoutOthers: ${_this.logoutOthers}, loading: ${_this.loading}, failure: ${_this.failure}, updated: ${_this.updated}, othersLoggedOut: ${_this.othersLoggedOut}, route: ${_this.route})';
}


}

/// @nodoc
abstract mixin class $ResetPasswordStateCopyWith<$Res>  {
  factory $ResetPasswordStateCopyWith(ResetPasswordState value, $Res Function(ResetPasswordState) _then) = _$ResetPasswordStateCopyWithImpl;
@useResult
$Res call({
 String? email, String password, String confirm, bool logoutOthers, bool loading, Failure? failure, bool updated, bool othersLoggedOut, String? route
});




}
/// @nodoc
class _$ResetPasswordStateCopyWithImpl<$Res>
    implements $ResetPasswordStateCopyWith<$Res> {
  _$ResetPasswordStateCopyWithImpl(this._self, this._then);

  final ResetPasswordState _self;
  final $Res Function(ResetPasswordState) _then;

/// Create a copy of ResetPasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = freezed,Object? password = null,Object? confirm = null,Object? logoutOthers = null,Object? loading = null,Object? failure = freezed,Object? updated = null,Object? othersLoggedOut = null,Object? route = freezed,}) {
  return _then(ResetPasswordState(
email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirm: null == confirm ? _self.confirm : confirm // ignore: cast_nullable_to_non_nullable
as String,logoutOthers: null == logoutOthers ? _self.logoutOthers : logoutOthers // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,updated: null == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as bool,othersLoggedOut: null == othersLoggedOut ? _self.othersLoggedOut : othersLoggedOut // ignore: cast_nullable_to_non_nullable
as bool,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResetPasswordState].
extension ResetPasswordStatePatterns on ResetPasswordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResetPasswordState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResetPasswordState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResetPasswordState value)  $default,){
final _that = this;
switch (_that) {
case _ResetPasswordState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResetPasswordState value)?  $default,){
final _that = this;
switch (_that) {
case _ResetPasswordState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? email,  String password,  String confirm,  bool logoutOthers,  bool loading,  Failure? failure,  bool updated,  bool othersLoggedOut,  String? route)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResetPasswordState() when $default != null:
return $default(_that.email,_that.password,_that.confirm,_that.logoutOthers,_that.loading,_that.failure,_that.updated,_that.othersLoggedOut,_that.route);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? email,  String password,  String confirm,  bool logoutOthers,  bool loading,  Failure? failure,  bool updated,  bool othersLoggedOut,  String? route)  $default,) {final _that = this;
switch (_that) {
case _ResetPasswordState():
return $default(_that.email,_that.password,_that.confirm,_that.logoutOthers,_that.loading,_that.failure,_that.updated,_that.othersLoggedOut,_that.route);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? email,  String password,  String confirm,  bool logoutOthers,  bool loading,  Failure? failure,  bool updated,  bool othersLoggedOut,  String? route)?  $default,) {final _that = this;
switch (_that) {
case _ResetPasswordState() when $default != null:
return $default(_that.email,_that.password,_that.confirm,_that.logoutOthers,_that.loading,_that.failure,_that.updated,_that.othersLoggedOut,_that.route);case _:
  return null;

}
}

}

/// @nodoc


class _ResetPasswordState extends ResetPasswordState {
  const _ResetPasswordState({this.email, this.password = '', this.confirm = '', this.logoutOthers = true, this.loading = false, this.failure, this.updated = false, this.othersLoggedOut = false, this.route}): super._();
  

/// The recovery session's email; null when no recovery session exists (the link expired).
@override final  String? email;
@override@JsonKey() final  String password;
@override@JsonKey() final  String confirm;
@override@JsonKey() final  bool logoutOthers;
@override@JsonKey() final  bool loading;
@override final  Failure? failure;
/// The password was changed; the screen shows the "Password updated" dialog.
@override@JsonKey() final  bool updated;
/// With [updated]: the other devices were signed out too (the body of the dialog says so).
@override@JsonKey() final  bool othersLoggedOut;
/// One-shot: where the screen goes next (Sign in).
@override final  String? route;

/// Create a copy of ResetPasswordState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResetPasswordStateCopyWith<_ResetPasswordState> get copyWith => __$ResetPasswordStateCopyWithImpl<_ResetPasswordState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetPasswordState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirm, confirm) || other.confirm == confirm)&&(identical(other.logoutOthers, logoutOthers) || other.logoutOthers == logoutOthers)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.othersLoggedOut, othersLoggedOut) || other.othersLoggedOut == othersLoggedOut)&&(identical(other.route, route) || other.route == route));
}


@override
int get hashCode {
    return Object.hash(runtimeType,email,password,confirm,logoutOthers,loading,failure,updated,othersLoggedOut,route);
}

@override
String toString() {
    return 'ResetPasswordState(email: $email, password: $password, confirm: $confirm, logoutOthers: $logoutOthers, loading: $loading, failure: $failure, updated: $updated, othersLoggedOut: $othersLoggedOut, route: $route)';
}


}

/// @nodoc
abstract mixin class _$ResetPasswordStateCopyWith<$Res> implements $ResetPasswordStateCopyWith<$Res> {
  factory _$ResetPasswordStateCopyWith(_ResetPasswordState value, $Res Function(_ResetPasswordState) _then) = __$ResetPasswordStateCopyWithImpl;
@override @useResult
$Res call({
 String? email, String password, String confirm, bool logoutOthers, bool loading, Failure? failure, bool updated, bool othersLoggedOut, String? route
});




}
/// @nodoc
class __$ResetPasswordStateCopyWithImpl<$Res>
    implements _$ResetPasswordStateCopyWith<$Res> {
  __$ResetPasswordStateCopyWithImpl(this._self, this._then);

  final _ResetPasswordState _self;
  final $Res Function(_ResetPasswordState) _then;

/// Create a copy of ResetPasswordState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = freezed,Object? password = null,Object? confirm = null,Object? logoutOthers = null,Object? loading = null,Object? failure = freezed,Object? updated = null,Object? othersLoggedOut = null,Object? route = freezed,}) {
  return _then(_ResetPasswordState(
email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirm: null == confirm ? _self.confirm : confirm // ignore: cast_nullable_to_non_nullable
as String,logoutOthers: null == logoutOthers ? _self.logoutOthers : logoutOthers // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,updated: null == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as bool,othersLoggedOut: null == othersLoggedOut ? _self.othersLoggedOut : othersLoggedOut // ignore: cast_nullable_to_non_nullable
as bool,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
