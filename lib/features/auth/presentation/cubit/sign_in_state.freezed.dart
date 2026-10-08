// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_in_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignInState {

 String get identifier; String get password; bool get loading;/// Sign in was pressed with an empty field; the empty ones then show a "required" caption.
 bool get showRequired;/// Why the last attempt failed; cleared when the user edits a field.
 Failure? get failure;/// Time left before another attempt is allowed (too many attempts); null when not throttled.
 Duration? get retryIn;/// One-shot: where the screen goes next. The Cubit clears it right after emitting it.
 String? get route;/// With [route]: replace the whole stack (signed in) rather than push (verify email).
 bool get clearStack;
/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignInStateCopyWith<SignInState> get copyWith => _$SignInStateCopyWithImpl<SignInState>(this as SignInState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SignInState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInState&&(identical(other.identifier, _this.identifier) || other.identifier == _this.identifier)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.showRequired, _this.showRequired) || other.showRequired == _this.showRequired)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.retryIn, _this.retryIn) || other.retryIn == _this.retryIn)&&(identical(other.route, _this.route) || other.route == _this.route)&&(identical(other.clearStack, _this.clearStack) || other.clearStack == _this.clearStack));
}


@override
int get hashCode {
  final _this = this as SignInState;
  return Object.hash(runtimeType,_this.identifier,_this.password,_this.loading,_this.showRequired,_this.failure,_this.retryIn,_this.route,_this.clearStack);
}

@override
String toString() {
  final _this = this as SignInState;
  return 'SignInState(identifier: ${_this.identifier}, password: ${_this.password}, loading: ${_this.loading}, showRequired: ${_this.showRequired}, failure: ${_this.failure}, retryIn: ${_this.retryIn}, route: ${_this.route}, clearStack: ${_this.clearStack})';
}


}

/// @nodoc
abstract mixin class $SignInStateCopyWith<$Res>  {
  factory $SignInStateCopyWith(SignInState value, $Res Function(SignInState) _then) = _$SignInStateCopyWithImpl;
@useResult
$Res call({
 String identifier, String password, bool loading, bool showRequired, Failure? failure, Duration? retryIn, String? route, bool clearStack
});




}
/// @nodoc
class _$SignInStateCopyWithImpl<$Res>
    implements $SignInStateCopyWith<$Res> {
  _$SignInStateCopyWithImpl(this._self, this._then);

  final SignInState _self;
  final $Res Function(SignInState) _then;

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identifier = null,Object? password = null,Object? loading = null,Object? showRequired = null,Object? failure = freezed,Object? retryIn = freezed,Object? route = freezed,Object? clearStack = null,}) {
  return _then(SignInState(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,showRequired: null == showRequired ? _self.showRequired : showRequired // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryIn: freezed == retryIn ? _self.retryIn : retryIn // ignore: cast_nullable_to_non_nullable
as Duration?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,clearStack: null == clearStack ? _self.clearStack : clearStack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SignInState].
extension SignInStatePatterns on SignInState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignInState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignInState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignInState value)  $default,){
final _that = this;
switch (_that) {
case _SignInState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignInState value)?  $default,){
final _that = this;
switch (_that) {
case _SignInState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String identifier,  String password,  bool loading,  bool showRequired,  Failure? failure,  Duration? retryIn,  String? route,  bool clearStack)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignInState() when $default != null:
return $default(_that.identifier,_that.password,_that.loading,_that.showRequired,_that.failure,_that.retryIn,_that.route,_that.clearStack);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String identifier,  String password,  bool loading,  bool showRequired,  Failure? failure,  Duration? retryIn,  String? route,  bool clearStack)  $default,) {final _that = this;
switch (_that) {
case _SignInState():
return $default(_that.identifier,_that.password,_that.loading,_that.showRequired,_that.failure,_that.retryIn,_that.route,_that.clearStack);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String identifier,  String password,  bool loading,  bool showRequired,  Failure? failure,  Duration? retryIn,  String? route,  bool clearStack)?  $default,) {final _that = this;
switch (_that) {
case _SignInState() when $default != null:
return $default(_that.identifier,_that.password,_that.loading,_that.showRequired,_that.failure,_that.retryIn,_that.route,_that.clearStack);case _:
  return null;

}
}

}

/// @nodoc


class _SignInState extends SignInState {
  const _SignInState({this.identifier = '', this.password = '', this.loading = false, this.showRequired = false, this.failure, this.retryIn, this.route, this.clearStack = false}): super._();
  

@override@JsonKey() final  String identifier;
@override@JsonKey() final  String password;
@override@JsonKey() final  bool loading;
/// Sign in was pressed with an empty field; the empty ones then show a "required" caption.
@override@JsonKey() final  bool showRequired;
/// Why the last attempt failed; cleared when the user edits a field.
@override final  Failure? failure;
/// Time left before another attempt is allowed (too many attempts); null when not throttled.
@override final  Duration? retryIn;
/// One-shot: where the screen goes next. The Cubit clears it right after emitting it.
@override final  String? route;
/// With [route]: replace the whole stack (signed in) rather than push (verify email).
@override@JsonKey() final  bool clearStack;

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignInStateCopyWith<_SignInState> get copyWith => __$SignInStateCopyWithImpl<_SignInState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignInState&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.password, password) || other.password == password)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.showRequired, showRequired) || other.showRequired == showRequired)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryIn, retryIn) || other.retryIn == retryIn)&&(identical(other.route, route) || other.route == route)&&(identical(other.clearStack, clearStack) || other.clearStack == clearStack));
}


@override
int get hashCode {
    return Object.hash(runtimeType,identifier,password,loading,showRequired,failure,retryIn,route,clearStack);
}

@override
String toString() {
    return 'SignInState(identifier: $identifier, password: $password, loading: $loading, showRequired: $showRequired, failure: $failure, retryIn: $retryIn, route: $route, clearStack: $clearStack)';
}


}

/// @nodoc
abstract mixin class _$SignInStateCopyWith<$Res> implements $SignInStateCopyWith<$Res> {
  factory _$SignInStateCopyWith(_SignInState value, $Res Function(_SignInState) _then) = __$SignInStateCopyWithImpl;
@override @useResult
$Res call({
 String identifier, String password, bool loading, bool showRequired, Failure? failure, Duration? retryIn, String? route, bool clearStack
});




}
/// @nodoc
class __$SignInStateCopyWithImpl<$Res>
    implements _$SignInStateCopyWith<$Res> {
  __$SignInStateCopyWithImpl(this._self, this._then);

  final _SignInState _self;
  final $Res Function(_SignInState) _then;

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identifier = null,Object? password = null,Object? loading = null,Object? showRequired = null,Object? failure = freezed,Object? retryIn = freezed,Object? route = freezed,Object? clearStack = null,}) {
  return _then(_SignInState(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,showRequired: null == showRequired ? _self.showRequired : showRequired // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryIn: freezed == retryIn ? _self.retryIn : retryIn // ignore: cast_nullable_to_non_nullable
as Duration?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,clearStack: null == clearStack ? _self.clearStack : clearStack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
