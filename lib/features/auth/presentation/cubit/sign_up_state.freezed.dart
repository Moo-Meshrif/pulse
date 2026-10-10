// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_up_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignUpState {

/// 1 to 6, as "Step N of 6" shows it.
 int get step; String get email; String get password; bool get termsAccepted;/// The field was left once, so its format error may show.
 bool get emailTouched; bool get passwordTouched;/// The 6 digits typed on the Verify email step.
 String get code;/// About you (step 3).
 String get fullName; String get username; bool get usernameTouched; DateTime? get birthday; Gender? get gender;/// Profile (step 4): everything is optional.
 PickedPhoto? get photo;/// The photo saved earlier, shown until a new one is picked.
 String? get avatarUrl;/// The saved photo was removed here; deleting it waits for Continue.
 bool get avatarRemoved; String get bio; String get city; String get phone; bool get phoneTouched;/// Interests (step 5): the topics, loaded when Profile is left.
 LoadStatus get interestsStatus; List<InterestModel> get interests; Set<int> get selectedInterests;/// Follow (step 6): the people per backend tab, loaded when Interests is left.
 FollowTab get followTab; Map<SuggestionTab, LoadStatus> get peopleStatus; Map<SuggestionTab, List<SuggestedProfileModel>> get people; Set<String> get following; bool get loading;/// A resumed sign-up is loading what it entered before; the steps wait for it.
 bool get resuming;/// Why the last request failed; cleared when the user edits the field it belongs to.
 Failure? get failure;/// One-shot: where the flow goes when it ends (Home, or Sign in after leaving). The Cubit clears it
/// right after emitting it.
 String? get route;/// Time left before "Resend code" works again; null when it works.
 Duration? get resendIn;
/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpStateCopyWith<SignUpState> get copyWith => _$SignUpStateCopyWithImpl<SignUpState>(this as SignUpState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SignUpState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpState&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.termsAccepted, _this.termsAccepted) || other.termsAccepted == _this.termsAccepted)&&(identical(other.emailTouched, _this.emailTouched) || other.emailTouched == _this.emailTouched)&&(identical(other.passwordTouched, _this.passwordTouched) || other.passwordTouched == _this.passwordTouched)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.usernameTouched, _this.usernameTouched) || other.usernameTouched == _this.usernameTouched)&&(identical(other.birthday, _this.birthday) || other.birthday == _this.birthday)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.photo, _this.photo) || other.photo == _this.photo)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.avatarRemoved, _this.avatarRemoved) || other.avatarRemoved == _this.avatarRemoved)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.phoneTouched, _this.phoneTouched) || other.phoneTouched == _this.phoneTouched)&&(identical(other.interestsStatus, _this.interestsStatus) || other.interestsStatus == _this.interestsStatus)&&const DeepCollectionEquality().equals(other.interests, _this.interests)&&const DeepCollectionEquality().equals(other.selectedInterests, _this.selectedInterests)&&(identical(other.followTab, _this.followTab) || other.followTab == _this.followTab)&&const DeepCollectionEquality().equals(other.peopleStatus, _this.peopleStatus)&&const DeepCollectionEquality().equals(other.people, _this.people)&&const DeepCollectionEquality().equals(other.following, _this.following)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.resuming, _this.resuming) || other.resuming == _this.resuming)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.route, _this.route) || other.route == _this.route)&&(identical(other.resendIn, _this.resendIn) || other.resendIn == _this.resendIn));
}


@override
int get hashCode {
  final _this = this as SignUpState;
  return Object.hashAll([runtimeType,_this.step,_this.email,_this.password,_this.termsAccepted,_this.emailTouched,_this.passwordTouched,_this.code,_this.fullName,_this.username,_this.usernameTouched,_this.birthday,_this.gender,_this.photo,_this.avatarUrl,_this.avatarRemoved,_this.bio,_this.city,_this.phone,_this.phoneTouched,_this.interestsStatus,const DeepCollectionEquality().hash(_this.interests),const DeepCollectionEquality().hash(_this.selectedInterests),_this.followTab,const DeepCollectionEquality().hash(_this.peopleStatus),const DeepCollectionEquality().hash(_this.people),const DeepCollectionEquality().hash(_this.following),_this.loading,_this.resuming,_this.failure,_this.route,_this.resendIn]);
}

@override
String toString() {
  final _this = this as SignUpState;
  return 'SignUpState(step: ${_this.step}, email: ${_this.email}, password: ${_this.password}, termsAccepted: ${_this.termsAccepted}, emailTouched: ${_this.emailTouched}, passwordTouched: ${_this.passwordTouched}, code: ${_this.code}, fullName: ${_this.fullName}, username: ${_this.username}, usernameTouched: ${_this.usernameTouched}, birthday: ${_this.birthday}, gender: ${_this.gender}, photo: ${_this.photo}, avatarUrl: ${_this.avatarUrl}, avatarRemoved: ${_this.avatarRemoved}, bio: ${_this.bio}, city: ${_this.city}, phone: ${_this.phone}, phoneTouched: ${_this.phoneTouched}, interestsStatus: ${_this.interestsStatus}, interests: ${_this.interests}, selectedInterests: ${_this.selectedInterests}, followTab: ${_this.followTab}, peopleStatus: ${_this.peopleStatus}, people: ${_this.people}, following: ${_this.following}, loading: ${_this.loading}, resuming: ${_this.resuming}, failure: ${_this.failure}, route: ${_this.route}, resendIn: ${_this.resendIn})';
}


}

/// @nodoc
abstract mixin class $SignUpStateCopyWith<$Res>  {
  factory $SignUpStateCopyWith(SignUpState value, $Res Function(SignUpState) _then) = _$SignUpStateCopyWithImpl;
@useResult
$Res call({
 int step, String email, String password, bool termsAccepted, bool emailTouched, bool passwordTouched, String code, String fullName, String username, bool usernameTouched, DateTime? birthday, Gender? gender, PickedPhoto? photo, String? avatarUrl, bool avatarRemoved, String bio, String city, String phone, bool phoneTouched, LoadStatus interestsStatus, List<InterestModel> interests, Set<int> selectedInterests, FollowTab followTab, Map<SuggestionTab, LoadStatus> peopleStatus, Map<SuggestionTab, List<SuggestedProfileModel>> people, Set<String> following, bool loading, bool resuming, Failure? failure, String? route, Duration? resendIn
});




}
/// @nodoc
class _$SignUpStateCopyWithImpl<$Res>
    implements $SignUpStateCopyWith<$Res> {
  _$SignUpStateCopyWithImpl(this._self, this._then);

  final SignUpState _self;
  final $Res Function(SignUpState) _then;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? email = null,Object? password = null,Object? termsAccepted = null,Object? emailTouched = null,Object? passwordTouched = null,Object? code = null,Object? fullName = null,Object? username = null,Object? usernameTouched = null,Object? birthday = freezed,Object? gender = freezed,Object? photo = freezed,Object? avatarUrl = freezed,Object? avatarRemoved = null,Object? bio = null,Object? city = null,Object? phone = null,Object? phoneTouched = null,Object? interestsStatus = null,Object? interests = null,Object? selectedInterests = null,Object? followTab = null,Object? peopleStatus = null,Object? people = null,Object? following = null,Object? loading = null,Object? resuming = null,Object? failure = freezed,Object? route = freezed,Object? resendIn = freezed,}) {
  return _then(SignUpState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,emailTouched: null == emailTouched ? _self.emailTouched : emailTouched // ignore: cast_nullable_to_non_nullable
as bool,passwordTouched: null == passwordTouched ? _self.passwordTouched : passwordTouched // ignore: cast_nullable_to_non_nullable
as bool,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,usernameTouched: null == usernameTouched ? _self.usernameTouched : usernameTouched // ignore: cast_nullable_to_non_nullable
as bool,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as PickedPhoto?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,avatarRemoved: null == avatarRemoved ? _self.avatarRemoved : avatarRemoved // ignore: cast_nullable_to_non_nullable
as bool,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,phoneTouched: null == phoneTouched ? _self.phoneTouched : phoneTouched // ignore: cast_nullable_to_non_nullable
as bool,interestsStatus: null == interestsStatus ? _self.interestsStatus : interestsStatus // ignore: cast_nullable_to_non_nullable
as LoadStatus,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<InterestModel>,selectedInterests: null == selectedInterests ? _self.selectedInterests : selectedInterests // ignore: cast_nullable_to_non_nullable
as Set<int>,followTab: null == followTab ? _self.followTab : followTab // ignore: cast_nullable_to_non_nullable
as FollowTab,peopleStatus: null == peopleStatus ? _self.peopleStatus : peopleStatus // ignore: cast_nullable_to_non_nullable
as Map<SuggestionTab, LoadStatus>,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as Map<SuggestionTab, List<SuggestedProfileModel>>,following: null == following ? _self.following : following // ignore: cast_nullable_to_non_nullable
as Set<String>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,resuming: null == resuming ? _self.resuming : resuming // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,resendIn: freezed == resendIn ? _self.resendIn : resendIn // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

}


/// Adds pattern-matching-related methods to [SignUpState].
extension SignUpStatePatterns on SignUpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignUpState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignUpState value)  $default,){
final _that = this;
switch (_that) {
case _SignUpState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignUpState value)?  $default,){
final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int step,  String email,  String password,  bool termsAccepted,  bool emailTouched,  bool passwordTouched,  String code,  String fullName,  String username,  bool usernameTouched,  DateTime? birthday,  Gender? gender,  PickedPhoto? photo,  String? avatarUrl,  bool avatarRemoved,  String bio,  String city,  String phone,  bool phoneTouched,  LoadStatus interestsStatus,  List<InterestModel> interests,  Set<int> selectedInterests,  FollowTab followTab,  Map<SuggestionTab, LoadStatus> peopleStatus,  Map<SuggestionTab, List<SuggestedProfileModel>> people,  Set<String> following,  bool loading,  bool resuming,  Failure? failure,  String? route,  Duration? resendIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
return $default(_that.step,_that.email,_that.password,_that.termsAccepted,_that.emailTouched,_that.passwordTouched,_that.code,_that.fullName,_that.username,_that.usernameTouched,_that.birthday,_that.gender,_that.photo,_that.avatarUrl,_that.avatarRemoved,_that.bio,_that.city,_that.phone,_that.phoneTouched,_that.interestsStatus,_that.interests,_that.selectedInterests,_that.followTab,_that.peopleStatus,_that.people,_that.following,_that.loading,_that.resuming,_that.failure,_that.route,_that.resendIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int step,  String email,  String password,  bool termsAccepted,  bool emailTouched,  bool passwordTouched,  String code,  String fullName,  String username,  bool usernameTouched,  DateTime? birthday,  Gender? gender,  PickedPhoto? photo,  String? avatarUrl,  bool avatarRemoved,  String bio,  String city,  String phone,  bool phoneTouched,  LoadStatus interestsStatus,  List<InterestModel> interests,  Set<int> selectedInterests,  FollowTab followTab,  Map<SuggestionTab, LoadStatus> peopleStatus,  Map<SuggestionTab, List<SuggestedProfileModel>> people,  Set<String> following,  bool loading,  bool resuming,  Failure? failure,  String? route,  Duration? resendIn)  $default,) {final _that = this;
switch (_that) {
case _SignUpState():
return $default(_that.step,_that.email,_that.password,_that.termsAccepted,_that.emailTouched,_that.passwordTouched,_that.code,_that.fullName,_that.username,_that.usernameTouched,_that.birthday,_that.gender,_that.photo,_that.avatarUrl,_that.avatarRemoved,_that.bio,_that.city,_that.phone,_that.phoneTouched,_that.interestsStatus,_that.interests,_that.selectedInterests,_that.followTab,_that.peopleStatus,_that.people,_that.following,_that.loading,_that.resuming,_that.failure,_that.route,_that.resendIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int step,  String email,  String password,  bool termsAccepted,  bool emailTouched,  bool passwordTouched,  String code,  String fullName,  String username,  bool usernameTouched,  DateTime? birthday,  Gender? gender,  PickedPhoto? photo,  String? avatarUrl,  bool avatarRemoved,  String bio,  String city,  String phone,  bool phoneTouched,  LoadStatus interestsStatus,  List<InterestModel> interests,  Set<int> selectedInterests,  FollowTab followTab,  Map<SuggestionTab, LoadStatus> peopleStatus,  Map<SuggestionTab, List<SuggestedProfileModel>> people,  Set<String> following,  bool loading,  bool resuming,  Failure? failure,  String? route,  Duration? resendIn)?  $default,) {final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
return $default(_that.step,_that.email,_that.password,_that.termsAccepted,_that.emailTouched,_that.passwordTouched,_that.code,_that.fullName,_that.username,_that.usernameTouched,_that.birthday,_that.gender,_that.photo,_that.avatarUrl,_that.avatarRemoved,_that.bio,_that.city,_that.phone,_that.phoneTouched,_that.interestsStatus,_that.interests,_that.selectedInterests,_that.followTab,_that.peopleStatus,_that.people,_that.following,_that.loading,_that.resuming,_that.failure,_that.route,_that.resendIn);case _:
  return null;

}
}

}

/// @nodoc


class _SignUpState extends SignUpState {
  const _SignUpState({this.step = 1, this.email = '', this.password = '', this.termsAccepted = false, this.emailTouched = false, this.passwordTouched = false, this.code = '', this.fullName = '', this.username = '', this.usernameTouched = false, this.birthday, this.gender, this.photo, this.avatarUrl, this.avatarRemoved = false, this.bio = '', this.city = '', this.phone = '', this.phoneTouched = false, this.interestsStatus = LoadStatus.idle,  List<InterestModel> interests = const [],  Set<int> selectedInterests = const {}, this.followTab = FollowTab.suggested,  Map<SuggestionTab, LoadStatus> peopleStatus = const {},  Map<SuggestionTab, List<SuggestedProfileModel>> people = const {},  Set<String> following = const {}, this.loading = false, this.resuming = false, this.failure, this.route, this.resendIn}): _interests = interests,_selectedInterests = selectedInterests,_peopleStatus = peopleStatus,_people = people,_following = following,super._();
  

/// 1 to 6, as "Step N of 6" shows it.
@override@JsonKey() final  int step;
@override@JsonKey() final  String email;
@override@JsonKey() final  String password;
@override@JsonKey() final  bool termsAccepted;
/// The field was left once, so its format error may show.
@override@JsonKey() final  bool emailTouched;
@override@JsonKey() final  bool passwordTouched;
/// The 6 digits typed on the Verify email step.
@override@JsonKey() final  String code;
/// About you (step 3).
@override@JsonKey() final  String fullName;
@override@JsonKey() final  String username;
@override@JsonKey() final  bool usernameTouched;
@override final  DateTime? birthday;
@override final  Gender? gender;
/// Profile (step 4): everything is optional.
@override final  PickedPhoto? photo;
/// The photo saved earlier, shown until a new one is picked.
@override final  String? avatarUrl;
/// The saved photo was removed here; deleting it waits for Continue.
@override@JsonKey() final  bool avatarRemoved;
@override@JsonKey() final  String bio;
@override@JsonKey() final  String city;
@override@JsonKey() final  String phone;
@override@JsonKey() final  bool phoneTouched;
/// Interests (step 5): the topics, loaded when Profile is left.
@override@JsonKey() final  LoadStatus interestsStatus;
 final  List<InterestModel> _interests;
@override@JsonKey() List<InterestModel> get interests {
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interests);
}

 final  Set<int> _selectedInterests;
@override@JsonKey() Set<int> get selectedInterests {
  if (_selectedInterests is EqualUnmodifiableSetView) return _selectedInterests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedInterests);
}

/// Follow (step 6): the people per backend tab, loaded when Interests is left.
@override@JsonKey() final  FollowTab followTab;
 final  Map<SuggestionTab, LoadStatus> _peopleStatus;
@override@JsonKey() Map<SuggestionTab, LoadStatus> get peopleStatus {
  if (_peopleStatus is EqualUnmodifiableMapView) return _peopleStatus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_peopleStatus);
}

 final  Map<SuggestionTab, List<SuggestedProfileModel>> _people;
@override@JsonKey() Map<SuggestionTab, List<SuggestedProfileModel>> get people {
  if (_people is EqualUnmodifiableMapView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_people);
}

 final  Set<String> _following;
@override@JsonKey() Set<String> get following {
  if (_following is EqualUnmodifiableSetView) return _following;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_following);
}

@override@JsonKey() final  bool loading;
/// A resumed sign-up is loading what it entered before; the steps wait for it.
@override@JsonKey() final  bool resuming;
/// Why the last request failed; cleared when the user edits the field it belongs to.
@override final  Failure? failure;
/// One-shot: where the flow goes when it ends (Home, or Sign in after leaving). The Cubit clears it
/// right after emitting it.
@override final  String? route;
/// Time left before "Resend code" works again; null when it works.
@override final  Duration? resendIn;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignUpStateCopyWith<_SignUpState> get copyWith => __$SignUpStateCopyWithImpl<_SignUpState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpState&&(identical(other.step, step) || other.step == step)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.emailTouched, emailTouched) || other.emailTouched == emailTouched)&&(identical(other.passwordTouched, passwordTouched) || other.passwordTouched == passwordTouched)&&(identical(other.code, code) || other.code == code)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.username, username) || other.username == username)&&(identical(other.usernameTouched, usernameTouched) || other.usernameTouched == usernameTouched)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.avatarRemoved, avatarRemoved) || other.avatarRemoved == avatarRemoved)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.city, city) || other.city == city)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.phoneTouched, phoneTouched) || other.phoneTouched == phoneTouched)&&(identical(other.interestsStatus, interestsStatus) || other.interestsStatus == interestsStatus)&&const DeepCollectionEquality().equals(other.interests, _interests)&&const DeepCollectionEquality().equals(other.selectedInterests, _selectedInterests)&&(identical(other.followTab, followTab) || other.followTab == followTab)&&const DeepCollectionEquality().equals(other.peopleStatus, _peopleStatus)&&const DeepCollectionEquality().equals(other.people, _people)&&const DeepCollectionEquality().equals(other.following, _following)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.resuming, resuming) || other.resuming == resuming)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.route, route) || other.route == route)&&(identical(other.resendIn, resendIn) || other.resendIn == resendIn));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,step,email,password,termsAccepted,emailTouched,passwordTouched,code,fullName,username,usernameTouched,birthday,gender,photo,avatarUrl,avatarRemoved,bio,city,phone,phoneTouched,interestsStatus,const DeepCollectionEquality().hash(_interests),const DeepCollectionEquality().hash(_selectedInterests),followTab,const DeepCollectionEquality().hash(_peopleStatus),const DeepCollectionEquality().hash(_people),const DeepCollectionEquality().hash(_following),loading,resuming,failure,route,resendIn]);
}

@override
String toString() {
    return 'SignUpState(step: $step, email: $email, password: $password, termsAccepted: $termsAccepted, emailTouched: $emailTouched, passwordTouched: $passwordTouched, code: $code, fullName: $fullName, username: $username, usernameTouched: $usernameTouched, birthday: $birthday, gender: $gender, photo: $photo, avatarUrl: $avatarUrl, avatarRemoved: $avatarRemoved, bio: $bio, city: $city, phone: $phone, phoneTouched: $phoneTouched, interestsStatus: $interestsStatus, interests: $interests, selectedInterests: $selectedInterests, followTab: $followTab, peopleStatus: $peopleStatus, people: $people, following: $following, loading: $loading, resuming: $resuming, failure: $failure, route: $route, resendIn: $resendIn)';
}


}

/// @nodoc
abstract mixin class _$SignUpStateCopyWith<$Res> implements $SignUpStateCopyWith<$Res> {
  factory _$SignUpStateCopyWith(_SignUpState value, $Res Function(_SignUpState) _then) = __$SignUpStateCopyWithImpl;
@override @useResult
$Res call({
 int step, String email, String password, bool termsAccepted, bool emailTouched, bool passwordTouched, String code, String fullName, String username, bool usernameTouched, DateTime? birthday, Gender? gender, PickedPhoto? photo, String? avatarUrl, bool avatarRemoved, String bio, String city, String phone, bool phoneTouched, LoadStatus interestsStatus, List<InterestModel> interests, Set<int> selectedInterests, FollowTab followTab, Map<SuggestionTab, LoadStatus> peopleStatus, Map<SuggestionTab, List<SuggestedProfileModel>> people, Set<String> following, bool loading, bool resuming, Failure? failure, String? route, Duration? resendIn
});




}
/// @nodoc
class __$SignUpStateCopyWithImpl<$Res>
    implements _$SignUpStateCopyWith<$Res> {
  __$SignUpStateCopyWithImpl(this._self, this._then);

  final _SignUpState _self;
  final $Res Function(_SignUpState) _then;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? email = null,Object? password = null,Object? termsAccepted = null,Object? emailTouched = null,Object? passwordTouched = null,Object? code = null,Object? fullName = null,Object? username = null,Object? usernameTouched = null,Object? birthday = freezed,Object? gender = freezed,Object? photo = freezed,Object? avatarUrl = freezed,Object? avatarRemoved = null,Object? bio = null,Object? city = null,Object? phone = null,Object? phoneTouched = null,Object? interestsStatus = null,Object? interests = null,Object? selectedInterests = null,Object? followTab = null,Object? peopleStatus = null,Object? people = null,Object? following = null,Object? loading = null,Object? resuming = null,Object? failure = freezed,Object? route = freezed,Object? resendIn = freezed,}) {
  return _then(_SignUpState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,emailTouched: null == emailTouched ? _self.emailTouched : emailTouched // ignore: cast_nullable_to_non_nullable
as bool,passwordTouched: null == passwordTouched ? _self.passwordTouched : passwordTouched // ignore: cast_nullable_to_non_nullable
as bool,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,usernameTouched: null == usernameTouched ? _self.usernameTouched : usernameTouched // ignore: cast_nullable_to_non_nullable
as bool,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as PickedPhoto?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,avatarRemoved: null == avatarRemoved ? _self.avatarRemoved : avatarRemoved // ignore: cast_nullable_to_non_nullable
as bool,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,phoneTouched: null == phoneTouched ? _self.phoneTouched : phoneTouched // ignore: cast_nullable_to_non_nullable
as bool,interestsStatus: null == interestsStatus ? _self.interestsStatus : interestsStatus // ignore: cast_nullable_to_non_nullable
as LoadStatus,interests: null == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<InterestModel>,selectedInterests: null == selectedInterests ? _self._selectedInterests : selectedInterests // ignore: cast_nullable_to_non_nullable
as Set<int>,followTab: null == followTab ? _self.followTab : followTab // ignore: cast_nullable_to_non_nullable
as FollowTab,peopleStatus: null == peopleStatus ? _self._peopleStatus : peopleStatus // ignore: cast_nullable_to_non_nullable
as Map<SuggestionTab, LoadStatus>,people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as Map<SuggestionTab, List<SuggestedProfileModel>>,following: null == following ? _self._following : following // ignore: cast_nullable_to_non_nullable
as Set<String>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,resuming: null == resuming ? _self.resuming : resuming // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,resendIn: freezed == resendIn ? _self.resendIn : resendIn // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

// dart format on
