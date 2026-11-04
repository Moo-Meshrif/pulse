// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'people_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PeopleState {

 ProfileStatus get status;/// What is typed in the search field; blank shows everyone.
 String get query; List<PersonModel> get people; bool get hasMore; LoadMoreStatus get more;/// A pull to refresh is running; the rows stay.
 bool get isRefreshing;/// The list is empty because the account is private and the signed-in user does not follow it.
 bool get isLocked;/// The signed-in user, who has no Follow button on their own row.
 String? get userId;/// One-shot: a follow or a refresh did not go through (a follow is put back).
 Failure? get failure;
/// Create a copy of PeopleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeopleStateCopyWith<PeopleState> get copyWith => _$PeopleStateCopyWithImpl<PeopleState>(this as PeopleState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PeopleState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeopleState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.query, _this.query) || other.query == _this.query)&&const DeepCollectionEquality().equals(other.people, _this.people)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.more, _this.more) || other.more == _this.more)&&(identical(other.isRefreshing, _this.isRefreshing) || other.isRefreshing == _this.isRefreshing)&&(identical(other.isLocked, _this.isLocked) || other.isLocked == _this.isLocked)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as PeopleState;
  return Object.hash(runtimeType,_this.status,_this.query,const DeepCollectionEquality().hash(_this.people),_this.hasMore,_this.more,_this.isRefreshing,_this.isLocked,_this.userId,_this.failure);
}

@override
String toString() {
  final _this = this as PeopleState;
  return 'PeopleState(status: ${_this.status}, query: ${_this.query}, people: ${_this.people}, hasMore: ${_this.hasMore}, more: ${_this.more}, isRefreshing: ${_this.isRefreshing}, isLocked: ${_this.isLocked}, userId: ${_this.userId}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $PeopleStateCopyWith<$Res>  {
  factory $PeopleStateCopyWith(PeopleState value, $Res Function(PeopleState) _then) = _$PeopleStateCopyWithImpl;
@useResult
$Res call({
 ProfileStatus status, String query, List<PersonModel> people, bool hasMore, LoadMoreStatus more, bool isRefreshing, bool isLocked, String? userId, Failure? failure
});




}
/// @nodoc
class _$PeopleStateCopyWithImpl<$Res>
    implements $PeopleStateCopyWith<$Res> {
  _$PeopleStateCopyWithImpl(this._self, this._then);

  final PeopleState _self;
  final $Res Function(PeopleState) _then;

/// Create a copy of PeopleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? query = null,Object? people = null,Object? hasMore = null,Object? more = null,Object? isRefreshing = null,Object? isLocked = null,Object? userId = freezed,Object? failure = freezed,}) {
  return _then(PeopleState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as List<PersonModel>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,more: null == more ? _self.more : more // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [PeopleState].
extension PeopleStatePatterns on PeopleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeopleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeopleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeopleState value)  $default,){
final _that = this;
switch (_that) {
case _PeopleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeopleState value)?  $default,){
final _that = this;
switch (_that) {
case _PeopleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProfileStatus status,  String query,  List<PersonModel> people,  bool hasMore,  LoadMoreStatus more,  bool isRefreshing,  bool isLocked,  String? userId,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeopleState() when $default != null:
return $default(_that.status,_that.query,_that.people,_that.hasMore,_that.more,_that.isRefreshing,_that.isLocked,_that.userId,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProfileStatus status,  String query,  List<PersonModel> people,  bool hasMore,  LoadMoreStatus more,  bool isRefreshing,  bool isLocked,  String? userId,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _PeopleState():
return $default(_that.status,_that.query,_that.people,_that.hasMore,_that.more,_that.isRefreshing,_that.isLocked,_that.userId,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProfileStatus status,  String query,  List<PersonModel> people,  bool hasMore,  LoadMoreStatus more,  bool isRefreshing,  bool isLocked,  String? userId,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _PeopleState() when $default != null:
return $default(_that.status,_that.query,_that.people,_that.hasMore,_that.more,_that.isRefreshing,_that.isLocked,_that.userId,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _PeopleState extends PeopleState {
  const _PeopleState({this.status = ProfileStatus.loading, this.query = '',  List<PersonModel> people = const <PersonModel>[], this.hasMore = false, this.more = LoadMoreStatus.idle, this.isRefreshing = false, this.isLocked = false, this.userId, this.failure}): _people = people,super._();
  

@override@JsonKey() final  ProfileStatus status;
/// What is typed in the search field; blank shows everyone.
@override@JsonKey() final  String query;
 final  List<PersonModel> _people;
@override@JsonKey() List<PersonModel> get people {
  if (_people is EqualUnmodifiableListView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_people);
}

@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  LoadMoreStatus more;
/// A pull to refresh is running; the rows stay.
@override@JsonKey() final  bool isRefreshing;
/// The list is empty because the account is private and the signed-in user does not follow it.
@override@JsonKey() final  bool isLocked;
/// The signed-in user, who has no Follow button on their own row.
@override final  String? userId;
/// One-shot: a follow or a refresh did not go through (a follow is put back).
@override final  Failure? failure;

/// Create a copy of PeopleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeopleStateCopyWith<_PeopleState> get copyWith => __$PeopleStateCopyWithImpl<_PeopleState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeopleState&&(identical(other.status, status) || other.status == status)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.people, _people)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.more, more) || other.more == more)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,query,const DeepCollectionEquality().hash(_people),hasMore,more,isRefreshing,isLocked,userId,failure);
}

@override
String toString() {
    return 'PeopleState(status: $status, query: $query, people: $people, hasMore: $hasMore, more: $more, isRefreshing: $isRefreshing, isLocked: $isLocked, userId: $userId, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$PeopleStateCopyWith<$Res> implements $PeopleStateCopyWith<$Res> {
  factory _$PeopleStateCopyWith(_PeopleState value, $Res Function(_PeopleState) _then) = __$PeopleStateCopyWithImpl;
@override @useResult
$Res call({
 ProfileStatus status, String query, List<PersonModel> people, bool hasMore, LoadMoreStatus more, bool isRefreshing, bool isLocked, String? userId, Failure? failure
});




}
/// @nodoc
class __$PeopleStateCopyWithImpl<$Res>
    implements _$PeopleStateCopyWith<$Res> {
  __$PeopleStateCopyWithImpl(this._self, this._then);

  final _PeopleState _self;
  final $Res Function(_PeopleState) _then;

/// Create a copy of PeopleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? query = null,Object? people = null,Object? hasMore = null,Object? more = null,Object? isRefreshing = null,Object? isLocked = null,Object? userId = freezed,Object? failure = freezed,}) {
  return _then(_PeopleState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as List<PersonModel>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,more: null == more ? _self.more : more // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
