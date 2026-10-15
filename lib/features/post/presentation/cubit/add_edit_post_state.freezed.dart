// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_edit_post_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddEditPostState {

/// Made once, so Retry finds the files an earlier attempt uploaded; the post's own id when editing.
 String get postId;/// The post being edited, as it was when the screen opened; null when adding.
 PostEntity? get original; String get caption;/// The media already on the post that stay; empty when adding.
 List<PostMediaEntity> get kept;/// Signed links for [kept] by object path; empty until they load.
 Map<String, String> get urls;/// Files picked on this device; they go after [kept].
 List<PickedMedia> get media;/// A frame of each picked video, by video path; a video without one draws a plain tile.
 Map<String, String> get posters; String? get location; bool get commentsEnabled; ContentAudience get visibility;/// The people tagged, with the spot each has on a photo when one was set.
 List<TagChoice> get tags;/// How the author feels, shown in the headline.
 PostMoodEntity? get mood;/// The audience the account starts new posts with; a narrower choice looks different on the chip.
 ContentAudience get defaultVisibility;/// One-shot: the post was handed over to be sent; the screen closes.
 bool get isSaved;/// One-shot message for the screen.
 NewPostNotice? get notice;
/// Create a copy of AddEditPostState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddEditPostStateCopyWith<AddEditPostState> get copyWith => _$AddEditPostStateCopyWithImpl<AddEditPostState>(this as AddEditPostState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddEditPostState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddEditPostState&&(identical(other.postId, _this.postId) || other.postId == _this.postId)&&(identical(other.original, _this.original) || other.original == _this.original)&&(identical(other.caption, _this.caption) || other.caption == _this.caption)&&const DeepCollectionEquality().equals(other.kept, _this.kept)&&const DeepCollectionEquality().equals(other.urls, _this.urls)&&const DeepCollectionEquality().equals(other.media, _this.media)&&const DeepCollectionEquality().equals(other.posters, _this.posters)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.commentsEnabled, _this.commentsEnabled) || other.commentsEnabled == _this.commentsEnabled)&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&(identical(other.mood, _this.mood) || other.mood == _this.mood)&&(identical(other.defaultVisibility, _this.defaultVisibility) || other.defaultVisibility == _this.defaultVisibility)&&(identical(other.isSaved, _this.isSaved) || other.isSaved == _this.isSaved)&&(identical(other.notice, _this.notice) || other.notice == _this.notice));
}


@override
int get hashCode {
  final _this = this as AddEditPostState;
  return Object.hash(runtimeType,_this.postId,_this.original,_this.caption,const DeepCollectionEquality().hash(_this.kept),const DeepCollectionEquality().hash(_this.urls),const DeepCollectionEquality().hash(_this.media),const DeepCollectionEquality().hash(_this.posters),_this.location,_this.commentsEnabled,_this.visibility,const DeepCollectionEquality().hash(_this.tags),_this.mood,_this.defaultVisibility,_this.isSaved,_this.notice);
}

@override
String toString() {
  final _this = this as AddEditPostState;
  return 'AddEditPostState(postId: ${_this.postId}, original: ${_this.original}, caption: ${_this.caption}, kept: ${_this.kept}, urls: ${_this.urls}, media: ${_this.media}, posters: ${_this.posters}, location: ${_this.location}, commentsEnabled: ${_this.commentsEnabled}, visibility: ${_this.visibility}, tags: ${_this.tags}, mood: ${_this.mood}, defaultVisibility: ${_this.defaultVisibility}, isSaved: ${_this.isSaved}, notice: ${_this.notice})';
}


}

/// @nodoc
abstract mixin class $AddEditPostStateCopyWith<$Res>  {
  factory $AddEditPostStateCopyWith(AddEditPostState value, $Res Function(AddEditPostState) _then) = _$AddEditPostStateCopyWithImpl;
@useResult
$Res call({
 String postId, PostEntity? original, String caption, List<PostMediaEntity> kept, Map<String, String> urls, List<PickedMedia> media, Map<String, String> posters, String? location, bool commentsEnabled, ContentAudience visibility, List<TagChoice> tags, PostMoodEntity? mood, ContentAudience defaultVisibility, bool isSaved, NewPostNotice? notice
});




}
/// @nodoc
class _$AddEditPostStateCopyWithImpl<$Res>
    implements $AddEditPostStateCopyWith<$Res> {
  _$AddEditPostStateCopyWithImpl(this._self, this._then);

  final AddEditPostState _self;
  final $Res Function(AddEditPostState) _then;

/// Create a copy of AddEditPostState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? original = freezed,Object? caption = null,Object? kept = null,Object? urls = null,Object? media = null,Object? posters = null,Object? location = freezed,Object? commentsEnabled = null,Object? visibility = null,Object? tags = null,Object? mood = freezed,Object? defaultVisibility = null,Object? isSaved = null,Object? notice = freezed,}) {
  return _then(AddEditPostState(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as PostEntity?,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,kept: null == kept ? _self.kept : kept // ignore: cast_nullable_to_non_nullable
as List<PostMediaEntity>,urls: null == urls ? _self.urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, String>,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<PickedMedia>,posters: null == posters ? _self.posters : posters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,commentsEnabled: null == commentsEnabled ? _self.commentsEnabled : commentsEnabled // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as ContentAudience,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagChoice>,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as PostMoodEntity?,defaultVisibility: null == defaultVisibility ? _self.defaultVisibility : defaultVisibility // ignore: cast_nullable_to_non_nullable
as ContentAudience,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as NewPostNotice?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddEditPostState].
extension AddEditPostStatePatterns on AddEditPostState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddEditPostState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddEditPostState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddEditPostState value)  $default,){
final _that = this;
switch (_that) {
case _AddEditPostState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddEditPostState value)?  $default,){
final _that = this;
switch (_that) {
case _AddEditPostState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String postId,  PostEntity? original,  String caption,  List<PostMediaEntity> kept,  Map<String, String> urls,  List<PickedMedia> media,  Map<String, String> posters,  String? location,  bool commentsEnabled,  ContentAudience visibility,  List<TagChoice> tags,  PostMoodEntity? mood,  ContentAudience defaultVisibility,  bool isSaved,  NewPostNotice? notice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddEditPostState() when $default != null:
return $default(_that.postId,_that.original,_that.caption,_that.kept,_that.urls,_that.media,_that.posters,_that.location,_that.commentsEnabled,_that.visibility,_that.tags,_that.mood,_that.defaultVisibility,_that.isSaved,_that.notice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String postId,  PostEntity? original,  String caption,  List<PostMediaEntity> kept,  Map<String, String> urls,  List<PickedMedia> media,  Map<String, String> posters,  String? location,  bool commentsEnabled,  ContentAudience visibility,  List<TagChoice> tags,  PostMoodEntity? mood,  ContentAudience defaultVisibility,  bool isSaved,  NewPostNotice? notice)  $default,) {final _that = this;
switch (_that) {
case _AddEditPostState():
return $default(_that.postId,_that.original,_that.caption,_that.kept,_that.urls,_that.media,_that.posters,_that.location,_that.commentsEnabled,_that.visibility,_that.tags,_that.mood,_that.defaultVisibility,_that.isSaved,_that.notice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String postId,  PostEntity? original,  String caption,  List<PostMediaEntity> kept,  Map<String, String> urls,  List<PickedMedia> media,  Map<String, String> posters,  String? location,  bool commentsEnabled,  ContentAudience visibility,  List<TagChoice> tags,  PostMoodEntity? mood,  ContentAudience defaultVisibility,  bool isSaved,  NewPostNotice? notice)?  $default,) {final _that = this;
switch (_that) {
case _AddEditPostState() when $default != null:
return $default(_that.postId,_that.original,_that.caption,_that.kept,_that.urls,_that.media,_that.posters,_that.location,_that.commentsEnabled,_that.visibility,_that.tags,_that.mood,_that.defaultVisibility,_that.isSaved,_that.notice);case _:
  return null;

}
}

}

/// @nodoc


class _AddEditPostState extends AddEditPostState {
  const _AddEditPostState({required this.postId, this.original, this.caption = '',  List<PostMediaEntity> kept = const [],  Map<String, String> urls = const {},  List<PickedMedia> media = const [],  Map<String, String> posters = const {}, this.location, this.commentsEnabled = true, this.visibility = ContentAudience.public,  List<TagChoice> tags = const <TagChoice>[], this.mood, this.defaultVisibility = ContentAudience.public, this.isSaved = false, this.notice}): _kept = kept,_urls = urls,_media = media,_posters = posters,_tags = tags,super._();
  

/// Made once, so Retry finds the files an earlier attempt uploaded; the post's own id when editing.
@override final  String postId;
/// The post being edited, as it was when the screen opened; null when adding.
@override final  PostEntity? original;
@override@JsonKey() final  String caption;
/// The media already on the post that stay; empty when adding.
 final  List<PostMediaEntity> _kept;
/// The media already on the post that stay; empty when adding.
@override@JsonKey() List<PostMediaEntity> get kept {
  if (_kept is EqualUnmodifiableListView) return _kept;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_kept);
}

/// Signed links for [kept] by object path; empty until they load.
 final  Map<String, String> _urls;
/// Signed links for [kept] by object path; empty until they load.
@override@JsonKey() Map<String, String> get urls {
  if (_urls is EqualUnmodifiableMapView) return _urls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_urls);
}

/// Files picked on this device; they go after [kept].
 final  List<PickedMedia> _media;
/// Files picked on this device; they go after [kept].
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
/// The people tagged, with the spot each has on a photo when one was set.
 final  List<TagChoice> _tags;
/// The people tagged, with the spot each has on a photo when one was set.
@override@JsonKey() List<TagChoice> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// How the author feels, shown in the headline.
@override final  PostMoodEntity? mood;
/// The audience the account starts new posts with; a narrower choice looks different on the chip.
@override@JsonKey() final  ContentAudience defaultVisibility;
/// One-shot: the post was handed over to be sent; the screen closes.
@override@JsonKey() final  bool isSaved;
/// One-shot message for the screen.
@override final  NewPostNotice? notice;

/// Create a copy of AddEditPostState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddEditPostStateCopyWith<_AddEditPostState> get copyWith => __$AddEditPostStateCopyWithImpl<_AddEditPostState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddEditPostState&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.original, original) || other.original == original)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other.kept, _kept)&&const DeepCollectionEquality().equals(other.urls, _urls)&&const DeepCollectionEquality().equals(other.media, _media)&&const DeepCollectionEquality().equals(other.posters, _posters)&&(identical(other.location, location) || other.location == location)&&(identical(other.commentsEnabled, commentsEnabled) || other.commentsEnabled == commentsEnabled)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&const DeepCollectionEquality().equals(other.tags, _tags)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.defaultVisibility, defaultVisibility) || other.defaultVisibility == defaultVisibility)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.notice, notice) || other.notice == notice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,postId,original,caption,const DeepCollectionEquality().hash(_kept),const DeepCollectionEquality().hash(_urls),const DeepCollectionEquality().hash(_media),const DeepCollectionEquality().hash(_posters),location,commentsEnabled,visibility,const DeepCollectionEquality().hash(_tags),mood,defaultVisibility,isSaved,notice);
}

@override
String toString() {
    return 'AddEditPostState(postId: $postId, original: $original, caption: $caption, kept: $kept, urls: $urls, media: $media, posters: $posters, location: $location, commentsEnabled: $commentsEnabled, visibility: $visibility, tags: $tags, mood: $mood, defaultVisibility: $defaultVisibility, isSaved: $isSaved, notice: $notice)';
}


}

/// @nodoc
abstract mixin class _$AddEditPostStateCopyWith<$Res> implements $AddEditPostStateCopyWith<$Res> {
  factory _$AddEditPostStateCopyWith(_AddEditPostState value, $Res Function(_AddEditPostState) _then) = __$AddEditPostStateCopyWithImpl;
@override @useResult
$Res call({
 String postId, PostEntity? original, String caption, List<PostMediaEntity> kept, Map<String, String> urls, List<PickedMedia> media, Map<String, String> posters, String? location, bool commentsEnabled, ContentAudience visibility, List<TagChoice> tags, PostMoodEntity? mood, ContentAudience defaultVisibility, bool isSaved, NewPostNotice? notice
});




}
/// @nodoc
class __$AddEditPostStateCopyWithImpl<$Res>
    implements _$AddEditPostStateCopyWith<$Res> {
  __$AddEditPostStateCopyWithImpl(this._self, this._then);

  final _AddEditPostState _self;
  final $Res Function(_AddEditPostState) _then;

/// Create a copy of AddEditPostState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? original = freezed,Object? caption = null,Object? kept = null,Object? urls = null,Object? media = null,Object? posters = null,Object? location = freezed,Object? commentsEnabled = null,Object? visibility = null,Object? tags = null,Object? mood = freezed,Object? defaultVisibility = null,Object? isSaved = null,Object? notice = freezed,}) {
  return _then(_AddEditPostState(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as PostEntity?,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,kept: null == kept ? _self._kept : kept // ignore: cast_nullable_to_non_nullable
as List<PostMediaEntity>,urls: null == urls ? _self._urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, String>,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<PickedMedia>,posters: null == posters ? _self._posters : posters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,commentsEnabled: null == commentsEnabled ? _self.commentsEnabled : commentsEnabled // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as ContentAudience,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagChoice>,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as PostMoodEntity?,defaultVisibility: null == defaultVisibility ? _self.defaultVisibility : defaultVisibility // ignore: cast_nullable_to_non_nullable
as ContentAudience,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as NewPostNotice?,
  ));
}


}

// dart format on
