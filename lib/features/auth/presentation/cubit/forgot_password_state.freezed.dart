// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forgot_password_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ForgotPasswordState {

 String get email;/// A send or a resend is in flight.
 bool get loading;/// The email is not shaped like an address; shown under the field until the user edits it.
 bool get invalidEmail;/// Why sending failed; the screen shows a snackbar.
 Failure? get failure;/// Time left before "Resend link" works; zero when it may be used.
 Duration get cooldown;/// One-shot: the link was sent to this email, so the screen opens the "link sent" dialog.
 String? get sentTo;/// One-shot: a notice for the dialog's snackbar.
 ResetLinkMessage? get message;/// Counts "Change email" taps: the view moves the focus to the field when it grows.
 int get focusRequest;
/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForgotPasswordStateCopyWith<ForgotPasswordState> get copyWith => _$ForgotPasswordStateCopyWithImpl<ForgotPasswordState>(this as ForgotPasswordState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ForgotPasswordState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordState&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.invalidEmail, _this.invalidEmail) || other.invalidEmail == _this.invalidEmail)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.cooldown, _this.cooldown) || other.cooldown == _this.cooldown)&&(identical(other.sentTo, _this.sentTo) || other.sentTo == _this.sentTo)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.focusRequest, _this.focusRequest) || other.focusRequest == _this.focusRequest));
}


@override
int get hashCode {
  final _this = this as ForgotPasswordState;
  return Object.hash(runtimeType,_this.email,_this.loading,_this.invalidEmail,_this.failure,_this.cooldown,_this.sentTo,_this.message,_this.focusRequest);
}

@override
String toString() {
  final _this = this as ForgotPasswordState;
  return 'ForgotPasswordState(email: ${_this.email}, loading: ${_this.loading}, invalidEmail: ${_this.invalidEmail}, failure: ${_this.failure}, cooldown: ${_this.cooldown}, sentTo: ${_this.sentTo}, message: ${_this.message}, focusRequest: ${_this.focusRequest})';
}


}

/// @nodoc
abstract mixin class $ForgotPasswordStateCopyWith<$Res>  {
  factory $ForgotPasswordStateCopyWith(ForgotPasswordState value, $Res Function(ForgotPasswordState) _then) = _$ForgotPasswordStateCopyWithImpl;
@useResult
$Res call({
 String email, bool loading, bool invalidEmail, Failure? failure, Duration cooldown, String? sentTo, ResetLinkMessage? message, int focusRequest
});




}
/// @nodoc
class _$ForgotPasswordStateCopyWithImpl<$Res>
    implements $ForgotPasswordStateCopyWith<$Res> {
  _$ForgotPasswordStateCopyWithImpl(this._self, this._then);

  final ForgotPasswordState _self;
  final $Res Function(ForgotPasswordState) _then;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? loading = null,Object? invalidEmail = null,Object? failure = freezed,Object? cooldown = null,Object? sentTo = freezed,Object? message = freezed,Object? focusRequest = null,}) {
  return _then(ForgotPasswordState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,invalidEmail: null == invalidEmail ? _self.invalidEmail : invalidEmail // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,cooldown: null == cooldown ? _self.cooldown : cooldown // ignore: cast_nullable_to_non_nullable
as Duration,sentTo: freezed == sentTo ? _self.sentTo : sentTo // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ResetLinkMessage?,focusRequest: null == focusRequest ? _self.focusRequest : focusRequest // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ForgotPasswordState].
extension ForgotPasswordStatePatterns on ForgotPasswordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForgotPasswordState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForgotPasswordState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForgotPasswordState value)  $default,){
final _that = this;
switch (_that) {
case _ForgotPasswordState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForgotPasswordState value)?  $default,){
final _that = this;
switch (_that) {
case _ForgotPasswordState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  bool loading,  bool invalidEmail,  Failure? failure,  Duration cooldown,  String? sentTo,  ResetLinkMessage? message,  int focusRequest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForgotPasswordState() when $default != null:
return $default(_that.email,_that.loading,_that.invalidEmail,_that.failure,_that.cooldown,_that.sentTo,_that.message,_that.focusRequest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  bool loading,  bool invalidEmail,  Failure? failure,  Duration cooldown,  String? sentTo,  ResetLinkMessage? message,  int focusRequest)  $default,) {final _that = this;
switch (_that) {
case _ForgotPasswordState():
return $default(_that.email,_that.loading,_that.invalidEmail,_that.failure,_that.cooldown,_that.sentTo,_that.message,_that.focusRequest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  bool loading,  bool invalidEmail,  Failure? failure,  Duration cooldown,  String? sentTo,  ResetLinkMessage? message,  int focusRequest)?  $default,) {final _that = this;
switch (_that) {
case _ForgotPasswordState() when $default != null:
return $default(_that.email,_that.loading,_that.invalidEmail,_that.failure,_that.cooldown,_that.sentTo,_that.message,_that.focusRequest);case _:
  return null;

}
}

}

/// @nodoc


class _ForgotPasswordState extends ForgotPasswordState {
  const _ForgotPasswordState({this.email = '', this.loading = false, this.invalidEmail = false, this.failure, this.cooldown = Duration.zero, this.sentTo, this.message, this.focusRequest = 0}): super._();
  

@override@JsonKey() final  String email;
/// A send or a resend is in flight.
@override@JsonKey() final  bool loading;
/// The email is not shaped like an address; shown under the field until the user edits it.
@override@JsonKey() final  bool invalidEmail;
/// Why sending failed; the screen shows a snackbar.
@override final  Failure? failure;
/// Time left before "Resend link" works; zero when it may be used.
@override@JsonKey() final  Duration cooldown;
/// One-shot: the link was sent to this email, so the screen opens the "link sent" dialog.
@override final  String? sentTo;
/// One-shot: a notice for the dialog's snackbar.
@override final  ResetLinkMessage? message;
/// Counts "Change email" taps: the view moves the focus to the field when it grows.
@override@JsonKey() final  int focusRequest;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForgotPasswordStateCopyWith<_ForgotPasswordState> get copyWith => __$ForgotPasswordStateCopyWithImpl<_ForgotPasswordState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForgotPasswordState&&(identical(other.email, email) || other.email == email)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.invalidEmail, invalidEmail) || other.invalidEmail == invalidEmail)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.cooldown, cooldown) || other.cooldown == cooldown)&&(identical(other.sentTo, sentTo) || other.sentTo == sentTo)&&(identical(other.message, message) || other.message == message)&&(identical(other.focusRequest, focusRequest) || other.focusRequest == focusRequest));
}


@override
int get hashCode {
    return Object.hash(runtimeType,email,loading,invalidEmail,failure,cooldown,sentTo,message,focusRequest);
}

@override
String toString() {
    return 'ForgotPasswordState(email: $email, loading: $loading, invalidEmail: $invalidEmail, failure: $failure, cooldown: $cooldown, sentTo: $sentTo, message: $message, focusRequest: $focusRequest)';
}


}

/// @nodoc
abstract mixin class _$ForgotPasswordStateCopyWith<$Res> implements $ForgotPasswordStateCopyWith<$Res> {
  factory _$ForgotPasswordStateCopyWith(_ForgotPasswordState value, $Res Function(_ForgotPasswordState) _then) = __$ForgotPasswordStateCopyWithImpl;
@override @useResult
$Res call({
 String email, bool loading, bool invalidEmail, Failure? failure, Duration cooldown, String? sentTo, ResetLinkMessage? message, int focusRequest
});




}
/// @nodoc
class __$ForgotPasswordStateCopyWithImpl<$Res>
    implements _$ForgotPasswordStateCopyWith<$Res> {
  __$ForgotPasswordStateCopyWithImpl(this._self, this._then);

  final _ForgotPasswordState _self;
  final $Res Function(_ForgotPasswordState) _then;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? loading = null,Object? invalidEmail = null,Object? failure = freezed,Object? cooldown = null,Object? sentTo = freezed,Object? message = freezed,Object? focusRequest = null,}) {
  return _then(_ForgotPasswordState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,invalidEmail: null == invalidEmail ? _self.invalidEmail : invalidEmail // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,cooldown: null == cooldown ? _self.cooldown : cooldown // ignore: cast_nullable_to_non_nullable
as Duration,sentTo: freezed == sentTo ? _self.sentTo : sentTo // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ResetLinkMessage?,focusRequest: null == focusRequest ? _self.focusRequest : focusRequest // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
