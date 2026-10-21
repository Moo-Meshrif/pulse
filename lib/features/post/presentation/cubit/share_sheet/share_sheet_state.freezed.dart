// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_sheet_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShareSheetState {

 String get caption; ContentAudience get audience;/// The audience the account starts new posts with; a narrower choice looks different on the chip.
 ContentAudience get defaultAudience; PostMoodEntity? get mood; String? get location; List<TagChoice> get tags;/// One-shot: how the last try ended; the sheet reacts and clears it.
 ShareResult? get result;
/// Create a copy of ShareSheetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareSheetStateCopyWith<ShareSheetState> get copyWith => _$ShareSheetStateCopyWithImpl<ShareSheetState>(this as ShareSheetState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ShareSheetState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareSheetState&&(identical(other.caption, _this.caption) || other.caption == _this.caption)&&(identical(other.audience, _this.audience) || other.audience == _this.audience)&&(identical(other.defaultAudience, _this.defaultAudience) || other.defaultAudience == _this.defaultAudience)&&(identical(other.mood, _this.mood) || other.mood == _this.mood)&&(identical(other.location, _this.location) || other.location == _this.location)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&(identical(other.result, _this.result) || other.result == _this.result));
}


@override
int get hashCode {
  final _this = this as ShareSheetState;
  return Object.hash(runtimeType,_this.caption,_this.audience,_this.defaultAudience,_this.mood,_this.location,const DeepCollectionEquality().hash(_this.tags),_this.result);
}

@override
String toString() {
  final _this = this as ShareSheetState;
  return 'ShareSheetState(caption: ${_this.caption}, audience: ${_this.audience}, defaultAudience: ${_this.defaultAudience}, mood: ${_this.mood}, location: ${_this.location}, tags: ${_this.tags}, result: ${_this.result})';
}


}

/// @nodoc
abstract mixin class $ShareSheetStateCopyWith<$Res>  {
  factory $ShareSheetStateCopyWith(ShareSheetState value, $Res Function(ShareSheetState) _then) = _$ShareSheetStateCopyWithImpl;
@useResult
$Res call({
 String caption, ContentAudience audience, ContentAudience defaultAudience, PostMoodEntity? mood, String? location, List<TagChoice> tags, ShareResult? result
});




}
/// @nodoc
class _$ShareSheetStateCopyWithImpl<$Res>
    implements $ShareSheetStateCopyWith<$Res> {
  _$ShareSheetStateCopyWithImpl(this._self, this._then);

  final ShareSheetState _self;
  final $Res Function(ShareSheetState) _then;

/// Create a copy of ShareSheetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? caption = null,Object? audience = null,Object? defaultAudience = null,Object? mood = freezed,Object? location = freezed,Object? tags = null,Object? result = freezed,}) {
  return _then(ShareSheetState(
caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as ContentAudience,defaultAudience: null == defaultAudience ? _self.defaultAudience : defaultAudience // ignore: cast_nullable_to_non_nullable
as ContentAudience,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as PostMoodEntity?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagChoice>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ShareResult?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShareSheetState].
extension ShareSheetStatePatterns on ShareSheetState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareSheetState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareSheetState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareSheetState value)  $default,){
final _that = this;
switch (_that) {
case _ShareSheetState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareSheetState value)?  $default,){
final _that = this;
switch (_that) {
case _ShareSheetState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String caption,  ContentAudience audience,  ContentAudience defaultAudience,  PostMoodEntity? mood,  String? location,  List<TagChoice> tags,  ShareResult? result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareSheetState() when $default != null:
return $default(_that.caption,_that.audience,_that.defaultAudience,_that.mood,_that.location,_that.tags,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String caption,  ContentAudience audience,  ContentAudience defaultAudience,  PostMoodEntity? mood,  String? location,  List<TagChoice> tags,  ShareResult? result)  $default,) {final _that = this;
switch (_that) {
case _ShareSheetState():
return $default(_that.caption,_that.audience,_that.defaultAudience,_that.mood,_that.location,_that.tags,_that.result);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String caption,  ContentAudience audience,  ContentAudience defaultAudience,  PostMoodEntity? mood,  String? location,  List<TagChoice> tags,  ShareResult? result)?  $default,) {final _that = this;
switch (_that) {
case _ShareSheetState() when $default != null:
return $default(_that.caption,_that.audience,_that.defaultAudience,_that.mood,_that.location,_that.tags,_that.result);case _:
  return null;

}
}

}

/// @nodoc


class _ShareSheetState extends ShareSheetState {
  const _ShareSheetState({this.caption = '', this.audience = ContentAudience.public, this.defaultAudience = ContentAudience.public, this.mood, this.location,  List<TagChoice> tags = const <TagChoice>[], this.result}): _tags = tags,super._();
  

@override@JsonKey() final  String caption;
@override@JsonKey() final  ContentAudience audience;
/// The audience the account starts new posts with; a narrower choice looks different on the chip.
@override@JsonKey() final  ContentAudience defaultAudience;
@override final  PostMoodEntity? mood;
@override final  String? location;
 final  List<TagChoice> _tags;
@override@JsonKey() List<TagChoice> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// One-shot: how the last try ended; the sheet reacts and clears it.
@override final  ShareResult? result;

/// Create a copy of ShareSheetState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareSheetStateCopyWith<_ShareSheetState> get copyWith => __$ShareSheetStateCopyWithImpl<_ShareSheetState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareSheetState&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.defaultAudience, defaultAudience) || other.defaultAudience == defaultAudience)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.tags, _tags)&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode {
    return Object.hash(runtimeType,caption,audience,defaultAudience,mood,location,const DeepCollectionEquality().hash(_tags),result);
}

@override
String toString() {
    return 'ShareSheetState(caption: $caption, audience: $audience, defaultAudience: $defaultAudience, mood: $mood, location: $location, tags: $tags, result: $result)';
}


}

/// @nodoc
abstract mixin class _$ShareSheetStateCopyWith<$Res> implements $ShareSheetStateCopyWith<$Res> {
  factory _$ShareSheetStateCopyWith(_ShareSheetState value, $Res Function(_ShareSheetState) _then) = __$ShareSheetStateCopyWithImpl;
@override @useResult
$Res call({
 String caption, ContentAudience audience, ContentAudience defaultAudience, PostMoodEntity? mood, String? location, List<TagChoice> tags, ShareResult? result
});




}
/// @nodoc
class __$ShareSheetStateCopyWithImpl<$Res>
    implements _$ShareSheetStateCopyWith<$Res> {
  __$ShareSheetStateCopyWithImpl(this._self, this._then);

  final _ShareSheetState _self;
  final $Res Function(_ShareSheetState) _then;

/// Create a copy of ShareSheetState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? caption = null,Object? audience = null,Object? defaultAudience = null,Object? mood = freezed,Object? location = freezed,Object? tags = null,Object? result = freezed,}) {
  return _then(_ShareSheetState(
caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as ContentAudience,defaultAudience: null == defaultAudience ? _self.defaultAudience : defaultAudience // ignore: cast_nullable_to_non_nullable
as ContentAudience,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as PostMoodEntity?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagChoice>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ShareResult?,
  ));
}


}

// dart format on
