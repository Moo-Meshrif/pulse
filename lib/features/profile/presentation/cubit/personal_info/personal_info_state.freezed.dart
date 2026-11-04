// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personal_info_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PersonalInfoState {

 bool get isLoading;/// Why the profile could not be read; the screen shows a retry.
 Failure? get loadFailure;/// The profile as saved; the edits are compared with it.
 ProfileEntity? get original; String get email; String get fullName; String get username; String get bio; String get city; String get phone; DateTime? get birthday;/// A new picture chosen but not saved yet.
 PickedPhoto? get avatar; bool get removeAvatar; PickedPhoto? get cover; bool get removeCover; UsernameStatus get usernameStatus; bool get isSaving;/// Saved: the screen shows the notice and leaves.
 bool get saved;/// Why the last save failed; the screen shows it once.
 Failure? get failure;
/// Create a copy of PersonalInfoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalInfoStateCopyWith<PersonalInfoState> get copyWith => _$PersonalInfoStateCopyWithImpl<PersonalInfoState>(this as PersonalInfoState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PersonalInfoState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalInfoState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.loadFailure, _this.loadFailure) || other.loadFailure == _this.loadFailure)&&(identical(other.original, _this.original) || other.original == _this.original)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.birthday, _this.birthday) || other.birthday == _this.birthday)&&(identical(other.avatar, _this.avatar) || other.avatar == _this.avatar)&&(identical(other.removeAvatar, _this.removeAvatar) || other.removeAvatar == _this.removeAvatar)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.removeCover, _this.removeCover) || other.removeCover == _this.removeCover)&&(identical(other.usernameStatus, _this.usernameStatus) || other.usernameStatus == _this.usernameStatus)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as PersonalInfoState;
  return Object.hash(runtimeType,_this.isLoading,_this.loadFailure,_this.original,_this.email,_this.fullName,_this.username,_this.bio,_this.city,_this.phone,_this.birthday,_this.avatar,_this.removeAvatar,_this.cover,_this.removeCover,_this.usernameStatus,_this.isSaving,_this.saved,_this.failure);
}

@override
String toString() {
  final _this = this as PersonalInfoState;
  return 'PersonalInfoState(isLoading: ${_this.isLoading}, loadFailure: ${_this.loadFailure}, original: ${_this.original}, email: ${_this.email}, fullName: ${_this.fullName}, username: ${_this.username}, bio: ${_this.bio}, city: ${_this.city}, phone: ${_this.phone}, birthday: ${_this.birthday}, avatar: ${_this.avatar}, removeAvatar: ${_this.removeAvatar}, cover: ${_this.cover}, removeCover: ${_this.removeCover}, usernameStatus: ${_this.usernameStatus}, isSaving: ${_this.isSaving}, saved: ${_this.saved}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $PersonalInfoStateCopyWith<$Res>  {
  factory $PersonalInfoStateCopyWith(PersonalInfoState value, $Res Function(PersonalInfoState) _then) = _$PersonalInfoStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, Failure? loadFailure, ProfileEntity? original, String email, String fullName, String username, String bio, String city, String phone, DateTime? birthday, PickedPhoto? avatar, bool removeAvatar, PickedPhoto? cover, bool removeCover, UsernameStatus usernameStatus, bool isSaving, bool saved, Failure? failure
});




}
/// @nodoc
class _$PersonalInfoStateCopyWithImpl<$Res>
    implements $PersonalInfoStateCopyWith<$Res> {
  _$PersonalInfoStateCopyWithImpl(this._self, this._then);

  final PersonalInfoState _self;
  final $Res Function(PersonalInfoState) _then;

/// Create a copy of PersonalInfoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? loadFailure = freezed,Object? original = freezed,Object? email = null,Object? fullName = null,Object? username = null,Object? bio = null,Object? city = null,Object? phone = null,Object? birthday = freezed,Object? avatar = freezed,Object? removeAvatar = null,Object? cover = freezed,Object? removeCover = null,Object? usernameStatus = null,Object? isSaving = null,Object? saved = null,Object? failure = freezed,}) {
  return _then(PersonalInfoState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as ProfileEntity?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as PickedPhoto?,removeAvatar: null == removeAvatar ? _self.removeAvatar : removeAvatar // ignore: cast_nullable_to_non_nullable
as bool,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as PickedPhoto?,removeCover: null == removeCover ? _self.removeCover : removeCover // ignore: cast_nullable_to_non_nullable
as bool,usernameStatus: null == usernameStatus ? _self.usernameStatus : usernameStatus // ignore: cast_nullable_to_non_nullable
as UsernameStatus,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonalInfoState].
extension PersonalInfoStatePatterns on PersonalInfoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalInfoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalInfoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalInfoState value)  $default,){
final _that = this;
switch (_that) {
case _PersonalInfoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalInfoState value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalInfoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  Failure? loadFailure,  ProfileEntity? original,  String email,  String fullName,  String username,  String bio,  String city,  String phone,  DateTime? birthday,  PickedPhoto? avatar,  bool removeAvatar,  PickedPhoto? cover,  bool removeCover,  UsernameStatus usernameStatus,  bool isSaving,  bool saved,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalInfoState() when $default != null:
return $default(_that.isLoading,_that.loadFailure,_that.original,_that.email,_that.fullName,_that.username,_that.bio,_that.city,_that.phone,_that.birthday,_that.avatar,_that.removeAvatar,_that.cover,_that.removeCover,_that.usernameStatus,_that.isSaving,_that.saved,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  Failure? loadFailure,  ProfileEntity? original,  String email,  String fullName,  String username,  String bio,  String city,  String phone,  DateTime? birthday,  PickedPhoto? avatar,  bool removeAvatar,  PickedPhoto? cover,  bool removeCover,  UsernameStatus usernameStatus,  bool isSaving,  bool saved,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _PersonalInfoState():
return $default(_that.isLoading,_that.loadFailure,_that.original,_that.email,_that.fullName,_that.username,_that.bio,_that.city,_that.phone,_that.birthday,_that.avatar,_that.removeAvatar,_that.cover,_that.removeCover,_that.usernameStatus,_that.isSaving,_that.saved,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  Failure? loadFailure,  ProfileEntity? original,  String email,  String fullName,  String username,  String bio,  String city,  String phone,  DateTime? birthday,  PickedPhoto? avatar,  bool removeAvatar,  PickedPhoto? cover,  bool removeCover,  UsernameStatus usernameStatus,  bool isSaving,  bool saved,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _PersonalInfoState() when $default != null:
return $default(_that.isLoading,_that.loadFailure,_that.original,_that.email,_that.fullName,_that.username,_that.bio,_that.city,_that.phone,_that.birthday,_that.avatar,_that.removeAvatar,_that.cover,_that.removeCover,_that.usernameStatus,_that.isSaving,_that.saved,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _PersonalInfoState extends PersonalInfoState {
  const _PersonalInfoState({this.isLoading = true, this.loadFailure, this.original, this.email = '', this.fullName = '', this.username = '', this.bio = '', this.city = '', this.phone = '', this.birthday, this.avatar, this.removeAvatar = false, this.cover, this.removeCover = false, this.usernameStatus = UsernameStatus.idle, this.isSaving = false, this.saved = false, this.failure}): super._();
  

@override@JsonKey() final  bool isLoading;
/// Why the profile could not be read; the screen shows a retry.
@override final  Failure? loadFailure;
/// The profile as saved; the edits are compared with it.
@override final  ProfileEntity? original;
@override@JsonKey() final  String email;
@override@JsonKey() final  String fullName;
@override@JsonKey() final  String username;
@override@JsonKey() final  String bio;
@override@JsonKey() final  String city;
@override@JsonKey() final  String phone;
@override final  DateTime? birthday;
/// A new picture chosen but not saved yet.
@override final  PickedPhoto? avatar;
@override@JsonKey() final  bool removeAvatar;
@override final  PickedPhoto? cover;
@override@JsonKey() final  bool removeCover;
@override@JsonKey() final  UsernameStatus usernameStatus;
@override@JsonKey() final  bool isSaving;
/// Saved: the screen shows the notice and leaves.
@override@JsonKey() final  bool saved;
/// Why the last save failed; the screen shows it once.
@override final  Failure? failure;

/// Create a copy of PersonalInfoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalInfoStateCopyWith<_PersonalInfoState> get copyWith => __$PersonalInfoStateCopyWithImpl<_PersonalInfoState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalInfoState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.loadFailure, loadFailure) || other.loadFailure == loadFailure)&&(identical(other.original, original) || other.original == original)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.username, username) || other.username == username)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.city, city) || other.city == city)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.removeAvatar, removeAvatar) || other.removeAvatar == removeAvatar)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.removeCover, removeCover) || other.removeCover == removeCover)&&(identical(other.usernameStatus, usernameStatus) || other.usernameStatus == usernameStatus)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading,loadFailure,original,email,fullName,username,bio,city,phone,birthday,avatar,removeAvatar,cover,removeCover,usernameStatus,isSaving,saved,failure);
}

@override
String toString() {
    return 'PersonalInfoState(isLoading: $isLoading, loadFailure: $loadFailure, original: $original, email: $email, fullName: $fullName, username: $username, bio: $bio, city: $city, phone: $phone, birthday: $birthday, avatar: $avatar, removeAvatar: $removeAvatar, cover: $cover, removeCover: $removeCover, usernameStatus: $usernameStatus, isSaving: $isSaving, saved: $saved, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$PersonalInfoStateCopyWith<$Res> implements $PersonalInfoStateCopyWith<$Res> {
  factory _$PersonalInfoStateCopyWith(_PersonalInfoState value, $Res Function(_PersonalInfoState) _then) = __$PersonalInfoStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, Failure? loadFailure, ProfileEntity? original, String email, String fullName, String username, String bio, String city, String phone, DateTime? birthday, PickedPhoto? avatar, bool removeAvatar, PickedPhoto? cover, bool removeCover, UsernameStatus usernameStatus, bool isSaving, bool saved, Failure? failure
});




}
/// @nodoc
class __$PersonalInfoStateCopyWithImpl<$Res>
    implements _$PersonalInfoStateCopyWith<$Res> {
  __$PersonalInfoStateCopyWithImpl(this._self, this._then);

  final _PersonalInfoState _self;
  final $Res Function(_PersonalInfoState) _then;

/// Create a copy of PersonalInfoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? loadFailure = freezed,Object? original = freezed,Object? email = null,Object? fullName = null,Object? username = null,Object? bio = null,Object? city = null,Object? phone = null,Object? birthday = freezed,Object? avatar = freezed,Object? removeAvatar = null,Object? cover = freezed,Object? removeCover = null,Object? usernameStatus = null,Object? isSaving = null,Object? saved = null,Object? failure = freezed,}) {
  return _then(_PersonalInfoState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,loadFailure: freezed == loadFailure ? _self.loadFailure : loadFailure // ignore: cast_nullable_to_non_nullable
as Failure?,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as ProfileEntity?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as PickedPhoto?,removeAvatar: null == removeAvatar ? _self.removeAvatar : removeAvatar // ignore: cast_nullable_to_non_nullable
as bool,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as PickedPhoto?,removeCover: null == removeCover ? _self.removeCover : removeCover // ignore: cast_nullable_to_non_nullable
as bool,usernameStatus: null == usernameStatus ? _self.usernameStatus : usernameStatus // ignore: cast_nullable_to_non_nullable
as UsernameStatus,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
