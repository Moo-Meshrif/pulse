// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_edit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoryEditState {

 CapturedStoryMedia get media; List<StorySticker> get stickers;/// Video only: the preview plays without sound.
 bool get isMuted; bool get isSharing; bool get isSaving;/// One-shot: the story was handed to the upload; the screen goes back to Home.
 bool get isShared;/// One-shot message for the screen.
 StoryEditNotice? get notice;
/// Create a copy of StoryEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryEditStateCopyWith<StoryEditState> get copyWith => _$StoryEditStateCopyWithImpl<StoryEditState>(this as StoryEditState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StoryEditState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryEditState&&(identical(other.media, _this.media) || other.media == _this.media)&&const DeepCollectionEquality().equals(other.stickers, _this.stickers)&&(identical(other.isMuted, _this.isMuted) || other.isMuted == _this.isMuted)&&(identical(other.isSharing, _this.isSharing) || other.isSharing == _this.isSharing)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.isShared, _this.isShared) || other.isShared == _this.isShared)&&(identical(other.notice, _this.notice) || other.notice == _this.notice));
}


@override
int get hashCode {
  final _this = this as StoryEditState;
  return Object.hash(runtimeType,_this.media,const DeepCollectionEquality().hash(_this.stickers),_this.isMuted,_this.isSharing,_this.isSaving,_this.isShared,_this.notice);
}

@override
String toString() {
  final _this = this as StoryEditState;
  return 'StoryEditState(media: ${_this.media}, stickers: ${_this.stickers}, isMuted: ${_this.isMuted}, isSharing: ${_this.isSharing}, isSaving: ${_this.isSaving}, isShared: ${_this.isShared}, notice: ${_this.notice})';
}


}

/// @nodoc
abstract mixin class $StoryEditStateCopyWith<$Res>  {
  factory $StoryEditStateCopyWith(StoryEditState value, $Res Function(StoryEditState) _then) = _$StoryEditStateCopyWithImpl;
@useResult
$Res call({
 CapturedStoryMedia media, List<StorySticker> stickers, bool isMuted, bool isSharing, bool isSaving, bool isShared, StoryEditNotice? notice
});




}
/// @nodoc
class _$StoryEditStateCopyWithImpl<$Res>
    implements $StoryEditStateCopyWith<$Res> {
  _$StoryEditStateCopyWithImpl(this._self, this._then);

  final StoryEditState _self;
  final $Res Function(StoryEditState) _then;

/// Create a copy of StoryEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? media = null,Object? stickers = null,Object? isMuted = null,Object? isSharing = null,Object? isSaving = null,Object? isShared = null,Object? notice = freezed,}) {
  return _then(StoryEditState(
media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as CapturedStoryMedia,stickers: null == stickers ? _self.stickers : stickers // ignore: cast_nullable_to_non_nullable
as List<StorySticker>,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isSharing: null == isSharing ? _self.isSharing : isSharing // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isShared: null == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as StoryEditNotice?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryEditState].
extension StoryEditStatePatterns on StoryEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryEditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryEditState value)  $default,){
final _that = this;
switch (_that) {
case _StoryEditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryEditState value)?  $default,){
final _that = this;
switch (_that) {
case _StoryEditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CapturedStoryMedia media,  List<StorySticker> stickers,  bool isMuted,  bool isSharing,  bool isSaving,  bool isShared,  StoryEditNotice? notice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryEditState() when $default != null:
return $default(_that.media,_that.stickers,_that.isMuted,_that.isSharing,_that.isSaving,_that.isShared,_that.notice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CapturedStoryMedia media,  List<StorySticker> stickers,  bool isMuted,  bool isSharing,  bool isSaving,  bool isShared,  StoryEditNotice? notice)  $default,) {final _that = this;
switch (_that) {
case _StoryEditState():
return $default(_that.media,_that.stickers,_that.isMuted,_that.isSharing,_that.isSaving,_that.isShared,_that.notice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CapturedStoryMedia media,  List<StorySticker> stickers,  bool isMuted,  bool isSharing,  bool isSaving,  bool isShared,  StoryEditNotice? notice)?  $default,) {final _that = this;
switch (_that) {
case _StoryEditState() when $default != null:
return $default(_that.media,_that.stickers,_that.isMuted,_that.isSharing,_that.isSaving,_that.isShared,_that.notice);case _:
  return null;

}
}

}

/// @nodoc


class _StoryEditState implements StoryEditState {
  const _StoryEditState({required this.media,  List<StorySticker> stickers = const [], this.isMuted = false, this.isSharing = false, this.isSaving = false, this.isShared = false, this.notice}): _stickers = stickers;
  

@override final  CapturedStoryMedia media;
 final  List<StorySticker> _stickers;
@override@JsonKey() List<StorySticker> get stickers {
  if (_stickers is EqualUnmodifiableListView) return _stickers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stickers);
}

/// Video only: the preview plays without sound.
@override@JsonKey() final  bool isMuted;
@override@JsonKey() final  bool isSharing;
@override@JsonKey() final  bool isSaving;
/// One-shot: the story was handed to the upload; the screen goes back to Home.
@override@JsonKey() final  bool isShared;
/// One-shot message for the screen.
@override final  StoryEditNotice? notice;

/// Create a copy of StoryEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryEditStateCopyWith<_StoryEditState> get copyWith => __$StoryEditStateCopyWithImpl<_StoryEditState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryEditState&&(identical(other.media, media) || other.media == media)&&const DeepCollectionEquality().equals(other.stickers, _stickers)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isSharing, isSharing) || other.isSharing == isSharing)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isShared, isShared) || other.isShared == isShared)&&(identical(other.notice, notice) || other.notice == notice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,media,const DeepCollectionEquality().hash(_stickers),isMuted,isSharing,isSaving,isShared,notice);
}

@override
String toString() {
    return 'StoryEditState(media: $media, stickers: $stickers, isMuted: $isMuted, isSharing: $isSharing, isSaving: $isSaving, isShared: $isShared, notice: $notice)';
}


}

/// @nodoc
abstract mixin class _$StoryEditStateCopyWith<$Res> implements $StoryEditStateCopyWith<$Res> {
  factory _$StoryEditStateCopyWith(_StoryEditState value, $Res Function(_StoryEditState) _then) = __$StoryEditStateCopyWithImpl;
@override @useResult
$Res call({
 CapturedStoryMedia media, List<StorySticker> stickers, bool isMuted, bool isSharing, bool isSaving, bool isShared, StoryEditNotice? notice
});




}
/// @nodoc
class __$StoryEditStateCopyWithImpl<$Res>
    implements _$StoryEditStateCopyWith<$Res> {
  __$StoryEditStateCopyWithImpl(this._self, this._then);

  final _StoryEditState _self;
  final $Res Function(_StoryEditState) _then;

/// Create a copy of StoryEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? media = null,Object? stickers = null,Object? isMuted = null,Object? isSharing = null,Object? isSaving = null,Object? isShared = null,Object? notice = freezed,}) {
  return _then(_StoryEditState(
media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as CapturedStoryMedia,stickers: null == stickers ? _self._stickers : stickers // ignore: cast_nullable_to_non_nullable
as List<StorySticker>,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isSharing: null == isSharing ? _self.isSharing : isSharing // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isShared: null == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as StoryEditNotice?,
  ));
}


}

// dart format on
