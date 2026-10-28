// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blocked_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BlockedState {

 ProfileStatus get status; List<BlockedPersonModel> get people; bool get hasMore; LoadMoreStatus get more;/// A pull to refresh is running; the rows stay.
 bool get isRefreshing;/// People whose Unblock is in flight.
 Set<String> get unblocking;/// One-shot: a refresh or an unblock did not go through.
 Failure? get failure;/// One-shot: the @username just unblocked, for the "Unblocked @name" notice.
 String? get unblockedUsername;
/// Create a copy of BlockedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockedStateCopyWith<BlockedState> get copyWith => _$BlockedStateCopyWithImpl<BlockedState>(this as BlockedState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BlockedState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockedState&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.people, _this.people)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.more, _this.more) || other.more == _this.more)&&(identical(other.isRefreshing, _this.isRefreshing) || other.isRefreshing == _this.isRefreshing)&&const DeepCollectionEquality().equals(other.unblocking, _this.unblocking)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.unblockedUsername, _this.unblockedUsername) || other.unblockedUsername == _this.unblockedUsername));
}


@override
int get hashCode {
  final _this = this as BlockedState;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.people),_this.hasMore,_this.more,_this.isRefreshing,const DeepCollectionEquality().hash(_this.unblocking),_this.failure,_this.unblockedUsername);
}

@override
String toString() {
  final _this = this as BlockedState;
  return 'BlockedState(status: ${_this.status}, people: ${_this.people}, hasMore: ${_this.hasMore}, more: ${_this.more}, isRefreshing: ${_this.isRefreshing}, unblocking: ${_this.unblocking}, failure: ${_this.failure}, unblockedUsername: ${_this.unblockedUsername})';
}


}

/// @nodoc
abstract mixin class $BlockedStateCopyWith<$Res>  {
  factory $BlockedStateCopyWith(BlockedState value, $Res Function(BlockedState) _then) = _$BlockedStateCopyWithImpl;
@useResult
$Res call({
 ProfileStatus status, List<BlockedPersonModel> people, bool hasMore, LoadMoreStatus more, bool isRefreshing, Set<String> unblocking, Failure? failure, String? unblockedUsername
});




}
/// @nodoc
class _$BlockedStateCopyWithImpl<$Res>
    implements $BlockedStateCopyWith<$Res> {
  _$BlockedStateCopyWithImpl(this._self, this._then);

  final BlockedState _self;
  final $Res Function(BlockedState) _then;

/// Create a copy of BlockedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? people = null,Object? hasMore = null,Object? more = null,Object? isRefreshing = null,Object? unblocking = null,Object? failure = freezed,Object? unblockedUsername = freezed,}) {
  return _then(BlockedState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as List<BlockedPersonModel>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,more: null == more ? _self.more : more // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,unblocking: null == unblocking ? _self.unblocking : unblocking // ignore: cast_nullable_to_non_nullable
as Set<String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,unblockedUsername: freezed == unblockedUsername ? _self.unblockedUsername : unblockedUsername // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BlockedState].
extension BlockedStatePatterns on BlockedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlockedState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlockedState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlockedState value)  $default,){
final _that = this;
switch (_that) {
case _BlockedState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlockedState value)?  $default,){
final _that = this;
switch (_that) {
case _BlockedState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProfileStatus status,  List<BlockedPersonModel> people,  bool hasMore,  LoadMoreStatus more,  bool isRefreshing,  Set<String> unblocking,  Failure? failure,  String? unblockedUsername)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlockedState() when $default != null:
return $default(_that.status,_that.people,_that.hasMore,_that.more,_that.isRefreshing,_that.unblocking,_that.failure,_that.unblockedUsername);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProfileStatus status,  List<BlockedPersonModel> people,  bool hasMore,  LoadMoreStatus more,  bool isRefreshing,  Set<String> unblocking,  Failure? failure,  String? unblockedUsername)  $default,) {final _that = this;
switch (_that) {
case _BlockedState():
return $default(_that.status,_that.people,_that.hasMore,_that.more,_that.isRefreshing,_that.unblocking,_that.failure,_that.unblockedUsername);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProfileStatus status,  List<BlockedPersonModel> people,  bool hasMore,  LoadMoreStatus more,  bool isRefreshing,  Set<String> unblocking,  Failure? failure,  String? unblockedUsername)?  $default,) {final _that = this;
switch (_that) {
case _BlockedState() when $default != null:
return $default(_that.status,_that.people,_that.hasMore,_that.more,_that.isRefreshing,_that.unblocking,_that.failure,_that.unblockedUsername);case _:
  return null;

}
}

}

/// @nodoc


class _BlockedState implements BlockedState {
  const _BlockedState({this.status = ProfileStatus.loading,  List<BlockedPersonModel> people = const <BlockedPersonModel>[], this.hasMore = false, this.more = LoadMoreStatus.idle, this.isRefreshing = false,  Set<String> unblocking = const <String>{}, this.failure, this.unblockedUsername}): _people = people,_unblocking = unblocking;
  

@override@JsonKey() final  ProfileStatus status;
 final  List<BlockedPersonModel> _people;
@override@JsonKey() List<BlockedPersonModel> get people {
  if (_people is EqualUnmodifiableListView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_people);
}

@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  LoadMoreStatus more;
/// A pull to refresh is running; the rows stay.
@override@JsonKey() final  bool isRefreshing;
/// People whose Unblock is in flight.
 final  Set<String> _unblocking;
/// People whose Unblock is in flight.
@override@JsonKey() Set<String> get unblocking {
  if (_unblocking is EqualUnmodifiableSetView) return _unblocking;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_unblocking);
}

/// One-shot: a refresh or an unblock did not go through.
@override final  Failure? failure;
/// One-shot: the @username just unblocked, for the "Unblocked @name" notice.
@override final  String? unblockedUsername;

/// Create a copy of BlockedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockedStateCopyWith<_BlockedState> get copyWith => __$BlockedStateCopyWithImpl<_BlockedState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlockedState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.people, _people)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.more, more) || other.more == more)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&const DeepCollectionEquality().equals(other.unblocking, _unblocking)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.unblockedUsername, unblockedUsername) || other.unblockedUsername == unblockedUsername));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_people),hasMore,more,isRefreshing,const DeepCollectionEquality().hash(_unblocking),failure,unblockedUsername);
}

@override
String toString() {
    return 'BlockedState(status: $status, people: $people, hasMore: $hasMore, more: $more, isRefreshing: $isRefreshing, unblocking: $unblocking, failure: $failure, unblockedUsername: $unblockedUsername)';
}


}

/// @nodoc
abstract mixin class _$BlockedStateCopyWith<$Res> implements $BlockedStateCopyWith<$Res> {
  factory _$BlockedStateCopyWith(_BlockedState value, $Res Function(_BlockedState) _then) = __$BlockedStateCopyWithImpl;
@override @useResult
$Res call({
 ProfileStatus status, List<BlockedPersonModel> people, bool hasMore, LoadMoreStatus more, bool isRefreshing, Set<String> unblocking, Failure? failure, String? unblockedUsername
});




}
/// @nodoc
class __$BlockedStateCopyWithImpl<$Res>
    implements _$BlockedStateCopyWith<$Res> {
  __$BlockedStateCopyWithImpl(this._self, this._then);

  final _BlockedState _self;
  final $Res Function(_BlockedState) _then;

/// Create a copy of BlockedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? people = null,Object? hasMore = null,Object? more = null,Object? isRefreshing = null,Object? unblocking = null,Object? failure = freezed,Object? unblockedUsername = freezed,}) {
  return _then(_BlockedState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as List<BlockedPersonModel>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,more: null == more ? _self.more : more // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,unblocking: null == unblocking ? _self._unblocking : unblocking // ignore: cast_nullable_to_non_nullable
as Set<String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,unblockedUsername: freezed == unblockedUsername ? _self.unblockedUsername : unblockedUsername // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
