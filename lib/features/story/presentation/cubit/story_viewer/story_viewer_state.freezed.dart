// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_viewer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoryViewerState {

 StoryViewerStatus get status; Failure? get failure; List<StoryRailItemEntity> get people; int get personIndex;/// Stories by author id; a person is missing until their list arrives.
 Map<String, List<StoryModel>> get stories; Set<String> get failedAuthors; int get storyIndex; Set<StoryPauseReason> get pauses;/// Grows when the first story of the first person is asked to go back: the story starts again.
 int get restarts;/// One-shot: the last story was passed, the screen closes.
 bool get isFinished;
/// Create a copy of StoryViewerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryViewerStateCopyWith<StoryViewerState> get copyWith => _$StoryViewerStateCopyWithImpl<StoryViewerState>(this as StoryViewerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StoryViewerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryViewerState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&const DeepCollectionEquality().equals(other.people, _this.people)&&(identical(other.personIndex, _this.personIndex) || other.personIndex == _this.personIndex)&&const DeepCollectionEquality().equals(other.stories, _this.stories)&&const DeepCollectionEquality().equals(other.failedAuthors, _this.failedAuthors)&&(identical(other.storyIndex, _this.storyIndex) || other.storyIndex == _this.storyIndex)&&const DeepCollectionEquality().equals(other.pauses, _this.pauses)&&(identical(other.restarts, _this.restarts) || other.restarts == _this.restarts)&&(identical(other.isFinished, _this.isFinished) || other.isFinished == _this.isFinished));
}


@override
int get hashCode {
  final _this = this as StoryViewerState;
  return Object.hash(runtimeType,_this.status,_this.failure,const DeepCollectionEquality().hash(_this.people),_this.personIndex,const DeepCollectionEquality().hash(_this.stories),const DeepCollectionEquality().hash(_this.failedAuthors),_this.storyIndex,const DeepCollectionEquality().hash(_this.pauses),_this.restarts,_this.isFinished);
}

@override
String toString() {
  final _this = this as StoryViewerState;
  return 'StoryViewerState(status: ${_this.status}, failure: ${_this.failure}, people: ${_this.people}, personIndex: ${_this.personIndex}, stories: ${_this.stories}, failedAuthors: ${_this.failedAuthors}, storyIndex: ${_this.storyIndex}, pauses: ${_this.pauses}, restarts: ${_this.restarts}, isFinished: ${_this.isFinished})';
}


}

/// @nodoc
abstract mixin class $StoryViewerStateCopyWith<$Res>  {
  factory $StoryViewerStateCopyWith(StoryViewerState value, $Res Function(StoryViewerState) _then) = _$StoryViewerStateCopyWithImpl;
@useResult
$Res call({
 StoryViewerStatus status, Failure? failure, List<StoryRailItemEntity> people, int personIndex, Map<String, List<StoryModel>> stories, Set<String> failedAuthors, int storyIndex, Set<StoryPauseReason> pauses, int restarts, bool isFinished
});




}
/// @nodoc
class _$StoryViewerStateCopyWithImpl<$Res>
    implements $StoryViewerStateCopyWith<$Res> {
  _$StoryViewerStateCopyWithImpl(this._self, this._then);

  final StoryViewerState _self;
  final $Res Function(StoryViewerState) _then;

/// Create a copy of StoryViewerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? failure = freezed,Object? people = null,Object? personIndex = null,Object? stories = null,Object? failedAuthors = null,Object? storyIndex = null,Object? pauses = null,Object? restarts = null,Object? isFinished = null,}) {
  return _then(StoryViewerState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StoryViewerStatus,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as List<StoryRailItemEntity>,personIndex: null == personIndex ? _self.personIndex : personIndex // ignore: cast_nullable_to_non_nullable
as int,stories: null == stories ? _self.stories : stories // ignore: cast_nullable_to_non_nullable
as Map<String, List<StoryModel>>,failedAuthors: null == failedAuthors ? _self.failedAuthors : failedAuthors // ignore: cast_nullable_to_non_nullable
as Set<String>,storyIndex: null == storyIndex ? _self.storyIndex : storyIndex // ignore: cast_nullable_to_non_nullable
as int,pauses: null == pauses ? _self.pauses : pauses // ignore: cast_nullable_to_non_nullable
as Set<StoryPauseReason>,restarts: null == restarts ? _self.restarts : restarts // ignore: cast_nullable_to_non_nullable
as int,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryViewerState].
extension StoryViewerStatePatterns on StoryViewerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryViewerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryViewerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryViewerState value)  $default,){
final _that = this;
switch (_that) {
case _StoryViewerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryViewerState value)?  $default,){
final _that = this;
switch (_that) {
case _StoryViewerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StoryViewerStatus status,  Failure? failure,  List<StoryRailItemEntity> people,  int personIndex,  Map<String, List<StoryModel>> stories,  Set<String> failedAuthors,  int storyIndex,  Set<StoryPauseReason> pauses,  int restarts,  bool isFinished)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryViewerState() when $default != null:
return $default(_that.status,_that.failure,_that.people,_that.personIndex,_that.stories,_that.failedAuthors,_that.storyIndex,_that.pauses,_that.restarts,_that.isFinished);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StoryViewerStatus status,  Failure? failure,  List<StoryRailItemEntity> people,  int personIndex,  Map<String, List<StoryModel>> stories,  Set<String> failedAuthors,  int storyIndex,  Set<StoryPauseReason> pauses,  int restarts,  bool isFinished)  $default,) {final _that = this;
switch (_that) {
case _StoryViewerState():
return $default(_that.status,_that.failure,_that.people,_that.personIndex,_that.stories,_that.failedAuthors,_that.storyIndex,_that.pauses,_that.restarts,_that.isFinished);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StoryViewerStatus status,  Failure? failure,  List<StoryRailItemEntity> people,  int personIndex,  Map<String, List<StoryModel>> stories,  Set<String> failedAuthors,  int storyIndex,  Set<StoryPauseReason> pauses,  int restarts,  bool isFinished)?  $default,) {final _that = this;
switch (_that) {
case _StoryViewerState() when $default != null:
return $default(_that.status,_that.failure,_that.people,_that.personIndex,_that.stories,_that.failedAuthors,_that.storyIndex,_that.pauses,_that.restarts,_that.isFinished);case _:
  return null;

}
}

}

/// @nodoc


class _StoryViewerState extends StoryViewerState {
  const _StoryViewerState({this.status = StoryViewerStatus.loading, this.failure,  List<StoryRailItemEntity> people = const [], this.personIndex = 0,  Map<String, List<StoryModel>> stories = const {},  Set<String> failedAuthors = const {}, this.storyIndex = 0,  Set<StoryPauseReason> pauses = const {}, this.restarts = 0, this.isFinished = false}): _people = people,_stories = stories,_failedAuthors = failedAuthors,_pauses = pauses,super._();
  

@override@JsonKey() final  StoryViewerStatus status;
@override final  Failure? failure;
 final  List<StoryRailItemEntity> _people;
@override@JsonKey() List<StoryRailItemEntity> get people {
  if (_people is EqualUnmodifiableListView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_people);
}

@override@JsonKey() final  int personIndex;
/// Stories by author id; a person is missing until their list arrives.
 final  Map<String, List<StoryModel>> _stories;
/// Stories by author id; a person is missing until their list arrives.
@override@JsonKey() Map<String, List<StoryModel>> get stories {
  if (_stories is EqualUnmodifiableMapView) return _stories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stories);
}

 final  Set<String> _failedAuthors;
@override@JsonKey() Set<String> get failedAuthors {
  if (_failedAuthors is EqualUnmodifiableSetView) return _failedAuthors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_failedAuthors);
}

@override@JsonKey() final  int storyIndex;
 final  Set<StoryPauseReason> _pauses;
@override@JsonKey() Set<StoryPauseReason> get pauses {
  if (_pauses is EqualUnmodifiableSetView) return _pauses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_pauses);
}

/// Grows when the first story of the first person is asked to go back: the story starts again.
@override@JsonKey() final  int restarts;
/// One-shot: the last story was passed, the screen closes.
@override@JsonKey() final  bool isFinished;

/// Create a copy of StoryViewerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryViewerStateCopyWith<_StoryViewerState> get copyWith => __$StoryViewerStateCopyWithImpl<_StoryViewerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryViewerState&&(identical(other.status, status) || other.status == status)&&(identical(other.failure, failure) || other.failure == failure)&&const DeepCollectionEquality().equals(other.people, _people)&&(identical(other.personIndex, personIndex) || other.personIndex == personIndex)&&const DeepCollectionEquality().equals(other.stories, _stories)&&const DeepCollectionEquality().equals(other.failedAuthors, _failedAuthors)&&(identical(other.storyIndex, storyIndex) || other.storyIndex == storyIndex)&&const DeepCollectionEquality().equals(other.pauses, _pauses)&&(identical(other.restarts, restarts) || other.restarts == restarts)&&(identical(other.isFinished, isFinished) || other.isFinished == isFinished));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,failure,const DeepCollectionEquality().hash(_people),personIndex,const DeepCollectionEquality().hash(_stories),const DeepCollectionEquality().hash(_failedAuthors),storyIndex,const DeepCollectionEquality().hash(_pauses),restarts,isFinished);
}

@override
String toString() {
    return 'StoryViewerState(status: $status, failure: $failure, people: $people, personIndex: $personIndex, stories: $stories, failedAuthors: $failedAuthors, storyIndex: $storyIndex, pauses: $pauses, restarts: $restarts, isFinished: $isFinished)';
}


}

/// @nodoc
abstract mixin class _$StoryViewerStateCopyWith<$Res> implements $StoryViewerStateCopyWith<$Res> {
  factory _$StoryViewerStateCopyWith(_StoryViewerState value, $Res Function(_StoryViewerState) _then) = __$StoryViewerStateCopyWithImpl;
@override @useResult
$Res call({
 StoryViewerStatus status, Failure? failure, List<StoryRailItemEntity> people, int personIndex, Map<String, List<StoryModel>> stories, Set<String> failedAuthors, int storyIndex, Set<StoryPauseReason> pauses, int restarts, bool isFinished
});




}
/// @nodoc
class __$StoryViewerStateCopyWithImpl<$Res>
    implements _$StoryViewerStateCopyWith<$Res> {
  __$StoryViewerStateCopyWithImpl(this._self, this._then);

  final _StoryViewerState _self;
  final $Res Function(_StoryViewerState) _then;

/// Create a copy of StoryViewerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? failure = freezed,Object? people = null,Object? personIndex = null,Object? stories = null,Object? failedAuthors = null,Object? storyIndex = null,Object? pauses = null,Object? restarts = null,Object? isFinished = null,}) {
  return _then(_StoryViewerState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StoryViewerStatus,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as List<StoryRailItemEntity>,personIndex: null == personIndex ? _self.personIndex : personIndex // ignore: cast_nullable_to_non_nullable
as int,stories: null == stories ? _self._stories : stories // ignore: cast_nullable_to_non_nullable
as Map<String, List<StoryModel>>,failedAuthors: null == failedAuthors ? _self._failedAuthors : failedAuthors // ignore: cast_nullable_to_non_nullable
as Set<String>,storyIndex: null == storyIndex ? _self.storyIndex : storyIndex // ignore: cast_nullable_to_non_nullable
as int,pauses: null == pauses ? _self._pauses : pauses // ignore: cast_nullable_to_non_nullable
as Set<StoryPauseReason>,restarts: null == restarts ? _self.restarts : restarts // ignore: cast_nullable_to_non_nullable
as int,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
