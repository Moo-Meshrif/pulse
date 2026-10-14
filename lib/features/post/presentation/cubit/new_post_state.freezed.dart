// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'new_post_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NewPostState {

/// Made once, so Retry finds the files an earlier attempt uploaded.
 String get postId; String get caption; List<PickedMedia> get media;/// A frame of each picked video, by video path; a video without one draws a plain tile.
 Map<String, String> get posters; String? get location; bool get commentsEnabled; ContentAudience get visibility;/// The audience the account starts new posts with; a narrower choice looks different on the chip.
 ContentAudience get defaultVisibility; bool get isSharing;/// One-shot: the post was shared; the screen closes.
 bool get isShared;/// One-shot message for the screen.
 NewPostNotice? get notice;
/// Create a copy of NewPostState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewPostStateCopyWith<NewPostState> get copyWith => _$NewPostStateCopyWithImpl<NewPostState>(this as NewPostState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NewPostState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewPostState&&(identical(other.postId, _this.postId) || other.postId == _this.postId)&&(identical(other.caption, _this.caption) || other.caption == _this.caption)&&const DeepCollectionEquality().equals(other.media, _this.media)&&const DeepCollectionEquality().equals(other.posters, _this.posters)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.commentsEnabled, _this.commentsEnabled) || other.commentsEnabled == _this.commentsEnabled)&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility)&&(identical(other.defaultVisibility, _this.defaultVisibility) || other.defaultVisibility == _this.defaultVisibility)&&(identical(other.isSharing, _this.isSharing) || other.isSharing == _this.isSharing)&&(identical(other.isShared, _this.isShared) || other.isShared == _this.isShared)&&(identical(other.notice, _this.notice) || other.notice == _this.notice));
}


@override
int get hashCode {
  final _this = this as NewPostState;
  return Object.hash(runtimeType,_this.postId,_this.caption,const DeepCollectionEquality().hash(_this.media),const DeepCollectionEquality().hash(_this.posters),_this.location,_this.commentsEnabled,_this.visibility,_this.defaultVisibility,_this.isSharing,_this.isShared,_this.notice);
}

@override
String toString() {
  final _this = this as NewPostState;
  return 'NewPostState(postId: ${_this.postId}, caption: ${_this.caption}, media: ${_this.media}, posters: ${_this.posters}, location: ${_this.location}, commentsEnabled: ${_this.commentsEnabled}, visibility: ${_this.visibility}, defaultVisibility: ${_this.defaultVisibility}, isSharing: ${_this.isSharing}, isShared: ${_this.isShared}, notice: ${_this.notice})';
}


}

/// @nodoc
abstract mixin class $NewPostStateCopyWith<$Res>  {
  factory $NewPostStateCopyWith(NewPostState value, $Res Function(NewPostState) _then) = _$NewPostStateCopyWithImpl;
@useResult
$Res call({
 String postId, String caption, List<PickedMedia> media, Map<String, String> posters, String? location, bool commentsEnabled, ContentAudience visibility, ContentAudience defaultVisibility, bool isSharing, bool isShared, NewPostNotice? notice
});




}
/// @nodoc
class _$NewPostStateCopyWithImpl<$Res>
    implements $NewPostStateCopyWith<$Res> {
  _$NewPostStateCopyWithImpl(this._self, this._then);

  final NewPostState _self;
  final $Res Function(NewPostState) _then;

/// Create a copy of NewPostState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? caption = null,Object? media = null,Object? posters = null,Object? location = freezed,Object? commentsEnabled = null,Object? visibility = null,Object? defaultVisibility = null,Object? isSharing = null,Object? isShared = null,Object? notice = freezed,}) {
  return _then(NewPostState(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<PickedMedia>,posters: null == posters ? _self.posters : posters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,commentsEnabled: null == commentsEnabled ? _self.commentsEnabled : commentsEnabled // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as ContentAudience,defaultVisibility: null == defaultVisibility ? _self.defaultVisibility : defaultVisibility // ignore: cast_nullable_to_non_nullable
as ContentAudience,isSharing: null == isSharing ? _self.isSharing : isSharing // ignore: cast_nullable_to_non_nullable
as bool,isShared: null == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as NewPostNotice?,
  ));
}

}


/// Adds pattern-matching-related methods to [NewPostState].
extension NewPostStatePatterns on NewPostState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewPostState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewPostState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewPostState value)  $default,){
final _that = this;
switch (_that) {
case _NewPostState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewPostState value)?  $default,){
final _that = this;
switch (_that) {
case _NewPostState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String postId,  String caption,  List<PickedMedia> media,  Map<String, String> posters,  String? location,  bool commentsEnabled,  ContentAudience visibility,  ContentAudience defaultVisibility,  bool isSharing,  bool isShared,  NewPostNotice? notice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewPostState() when $default != null:
return $default(_that.postId,_that.caption,_that.media,_that.posters,_that.location,_that.commentsEnabled,_that.visibility,_that.defaultVisibility,_that.isSharing,_that.isShared,_that.notice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String postId,  String caption,  List<PickedMedia> media,  Map<String, String> posters,  String? location,  bool commentsEnabled,  ContentAudience visibility,  ContentAudience defaultVisibility,  bool isSharing,  bool isShared,  NewPostNotice? notice)  $default,) {final _that = this;
switch (_that) {
case _NewPostState():
return $default(_that.postId,_that.caption,_that.media,_that.posters,_that.location,_that.commentsEnabled,_that.visibility,_that.defaultVisibility,_that.isSharing,_that.isShared,_that.notice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String postId,  String caption,  List<PickedMedia> media,  Map<String, String> posters,  String? location,  bool commentsEnabled,  ContentAudience visibility,  ContentAudience defaultVisibility,  bool isSharing,  bool isShared,  NewPostNotice? notice)?  $default,) {final _that = this;
switch (_that) {
case _NewPostState() when $default != null:
return $default(_that.postId,_that.caption,_that.media,_that.posters,_that.location,_that.commentsEnabled,_that.visibility,_that.defaultVisibility,_that.isSharing,_that.isShared,_that.notice);case _:
  return null;

}
}

}

/// @nodoc


class _NewPostState extends NewPostState {
  const _NewPostState({required this.postId, this.caption = '',  List<PickedMedia> media = const [],  Map<String, String> posters = const {}, this.location, this.commentsEnabled = true, this.visibility = ContentAudience.public, this.defaultVisibility = ContentAudience.public, this.isSharing = false, this.isShared = false, this.notice}): _media = media,_posters = posters,super._();
  

/// Made once, so Retry finds the files an earlier attempt uploaded.
@override final  String postId;
@override@JsonKey() final  String caption;
 final  List<PickedMedia> _media;
@override@JsonKey() List<PickedMedia> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}

/// A frame of each picked video, by video path; a video without one draws a plain tile.
 final  Map<String, String> _posters;
/// A frame of each picked video, by video path; a video without one draws a plain tile.
@override@JsonKey() Map<String, String> get posters {
  if (_posters is EqualUnmodifiableMapView) return _posters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_posters);
}

@override final  String? location;
@override@JsonKey() final  bool commentsEnabled;
@override@JsonKey() final  ContentAudience visibility;
/// The audience the account starts new posts with; a narrower choice looks different on the chip.
@override@JsonKey() final  ContentAudience defaultVisibility;
@override@JsonKey() final  bool isSharing;
/// One-shot: the post was shared; the screen closes.
@override@JsonKey() final  bool isShared;
/// One-shot message for the screen.
@override final  NewPostNotice? notice;

/// Create a copy of NewPostState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewPostStateCopyWith<_NewPostState> get copyWith => __$NewPostStateCopyWithImpl<_NewPostState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewPostState&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other.media, _media)&&const DeepCollectionEquality().equals(other.posters, _posters)&&(identical(other.location, location) || other.location == location)&&(identical(other.commentsEnabled, commentsEnabled) || other.commentsEnabled == commentsEnabled)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.defaultVisibility, defaultVisibility) || other.defaultVisibility == defaultVisibility)&&(identical(other.isSharing, isSharing) || other.isSharing == isSharing)&&(identical(other.isShared, isShared) || other.isShared == isShared)&&(identical(other.notice, notice) || other.notice == notice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,postId,caption,const DeepCollectionEquality().hash(_media),const DeepCollectionEquality().hash(_posters),location,commentsEnabled,visibility,defaultVisibility,isSharing,isShared,notice);
}

@override
String toString() {
    return 'NewPostState(postId: $postId, caption: $caption, media: $media, posters: $posters, location: $location, commentsEnabled: $commentsEnabled, visibility: $visibility, defaultVisibility: $defaultVisibility, isSharing: $isSharing, isShared: $isShared, notice: $notice)';
}


}

/// @nodoc
abstract mixin class _$NewPostStateCopyWith<$Res> implements $NewPostStateCopyWith<$Res> {
  factory _$NewPostStateCopyWith(_NewPostState value, $Res Function(_NewPostState) _then) = __$NewPostStateCopyWithImpl;
@override @useResult
$Res call({
 String postId, String caption, List<PickedMedia> media, Map<String, String> posters, String? location, bool commentsEnabled, ContentAudience visibility, ContentAudience defaultVisibility, bool isSharing, bool isShared, NewPostNotice? notice
});




}
/// @nodoc
class __$NewPostStateCopyWithImpl<$Res>
    implements _$NewPostStateCopyWith<$Res> {
  __$NewPostStateCopyWithImpl(this._self, this._then);

  final _NewPostState _self;
  final $Res Function(_NewPostState) _then;

/// Create a copy of NewPostState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? caption = null,Object? media = null,Object? posters = null,Object? location = freezed,Object? commentsEnabled = null,Object? visibility = null,Object? defaultVisibility = null,Object? isSharing = null,Object? isShared = null,Object? notice = freezed,}) {
  return _then(_NewPostState(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<PickedMedia>,posters: null == posters ? _self._posters : posters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,commentsEnabled: null == commentsEnabled ? _self.commentsEnabled : commentsEnabled // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as ContentAudience,defaultVisibility: null == defaultVisibility ? _self.defaultVisibility : defaultVisibility // ignore: cast_nullable_to_non_nullable
as ContentAudience,isSharing: null == isSharing ? _self.isSharing : isSharing // ignore: cast_nullable_to_non_nullable
as bool,isShared: null == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as NewPostNotice?,
  ));
}


}

// dart format on
