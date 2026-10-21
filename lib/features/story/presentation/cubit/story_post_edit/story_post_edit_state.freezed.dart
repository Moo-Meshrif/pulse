// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_post_edit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoryPostEditState {

 StoryPostArgs get post;/// The six backgrounds the palette tool offers; the first follows the post's picture once it is read.
 List<StoryPostBackground> get backgrounds; StoryPostStickerStyle get style;/// Where the post sticker sits (fractions of the screen), how big and how it is turned (degrees).
 double get x; double get y; double get scale; double get rotation; int get backgroundIndex;/// The swatches show where the hint was.
 bool get isPaletteOpen;/// The text on the story.
 List<StorySticker> get stickers; bool get isSharing; bool get isSaving;/// One-shot: the story was handed to the upload; the screen goes back to Home.
 bool get isShared;/// One-shot message for the screen.
 StoryEditNotice? get notice;
/// Create a copy of StoryPostEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryPostEditStateCopyWith<StoryPostEditState> get copyWith => _$StoryPostEditStateCopyWithImpl<StoryPostEditState>(this as StoryPostEditState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StoryPostEditState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryPostEditState&&(identical(other.post, _this.post) || other.post == _this.post)&&const DeepCollectionEquality().equals(other.backgrounds, _this.backgrounds)&&(identical(other.style, _this.style) || other.style == _this.style)&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.y, _this.y) || other.y == _this.y)&&(identical(other.scale, _this.scale) || other.scale == _this.scale)&&(identical(other.rotation, _this.rotation) || other.rotation == _this.rotation)&&(identical(other.backgroundIndex, _this.backgroundIndex) || other.backgroundIndex == _this.backgroundIndex)&&(identical(other.isPaletteOpen, _this.isPaletteOpen) || other.isPaletteOpen == _this.isPaletteOpen)&&const DeepCollectionEquality().equals(other.stickers, _this.stickers)&&(identical(other.isSharing, _this.isSharing) || other.isSharing == _this.isSharing)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.isShared, _this.isShared) || other.isShared == _this.isShared)&&(identical(other.notice, _this.notice) || other.notice == _this.notice));
}


@override
int get hashCode {
  final _this = this as StoryPostEditState;
  return Object.hash(runtimeType,_this.post,const DeepCollectionEquality().hash(_this.backgrounds),_this.style,_this.x,_this.y,_this.scale,_this.rotation,_this.backgroundIndex,_this.isPaletteOpen,const DeepCollectionEquality().hash(_this.stickers),_this.isSharing,_this.isSaving,_this.isShared,_this.notice);
}

@override
String toString() {
  final _this = this as StoryPostEditState;
  return 'StoryPostEditState(post: ${_this.post}, backgrounds: ${_this.backgrounds}, style: ${_this.style}, x: ${_this.x}, y: ${_this.y}, scale: ${_this.scale}, rotation: ${_this.rotation}, backgroundIndex: ${_this.backgroundIndex}, isPaletteOpen: ${_this.isPaletteOpen}, stickers: ${_this.stickers}, isSharing: ${_this.isSharing}, isSaving: ${_this.isSaving}, isShared: ${_this.isShared}, notice: ${_this.notice})';
}


}

/// @nodoc
abstract mixin class $StoryPostEditStateCopyWith<$Res>  {
  factory $StoryPostEditStateCopyWith(StoryPostEditState value, $Res Function(StoryPostEditState) _then) = _$StoryPostEditStateCopyWithImpl;
@useResult
$Res call({
 StoryPostArgs post, List<StoryPostBackground> backgrounds, StoryPostStickerStyle style, double x, double y, double scale, double rotation, int backgroundIndex, bool isPaletteOpen, List<StorySticker> stickers, bool isSharing, bool isSaving, bool isShared, StoryEditNotice? notice
});




}
/// @nodoc
class _$StoryPostEditStateCopyWithImpl<$Res>
    implements $StoryPostEditStateCopyWith<$Res> {
  _$StoryPostEditStateCopyWithImpl(this._self, this._then);

  final StoryPostEditState _self;
  final $Res Function(StoryPostEditState) _then;

/// Create a copy of StoryPostEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? post = null,Object? backgrounds = null,Object? style = null,Object? x = null,Object? y = null,Object? scale = null,Object? rotation = null,Object? backgroundIndex = null,Object? isPaletteOpen = null,Object? stickers = null,Object? isSharing = null,Object? isSaving = null,Object? isShared = null,Object? notice = freezed,}) {
  return _then(StoryPostEditState(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as StoryPostArgs,backgrounds: null == backgrounds ? _self.backgrounds : backgrounds // ignore: cast_nullable_to_non_nullable
as List<StoryPostBackground>,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as StoryPostStickerStyle,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,backgroundIndex: null == backgroundIndex ? _self.backgroundIndex : backgroundIndex // ignore: cast_nullable_to_non_nullable
as int,isPaletteOpen: null == isPaletteOpen ? _self.isPaletteOpen : isPaletteOpen // ignore: cast_nullable_to_non_nullable
as bool,stickers: null == stickers ? _self.stickers : stickers // ignore: cast_nullable_to_non_nullable
as List<StorySticker>,isSharing: null == isSharing ? _self.isSharing : isSharing // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isShared: null == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as StoryEditNotice?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryPostEditState].
extension StoryPostEditStatePatterns on StoryPostEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryPostEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryPostEditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryPostEditState value)  $default,){
final _that = this;
switch (_that) {
case _StoryPostEditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryPostEditState value)?  $default,){
final _that = this;
switch (_that) {
case _StoryPostEditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StoryPostArgs post,  List<StoryPostBackground> backgrounds,  StoryPostStickerStyle style,  double x,  double y,  double scale,  double rotation,  int backgroundIndex,  bool isPaletteOpen,  List<StorySticker> stickers,  bool isSharing,  bool isSaving,  bool isShared,  StoryEditNotice? notice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryPostEditState() when $default != null:
return $default(_that.post,_that.backgrounds,_that.style,_that.x,_that.y,_that.scale,_that.rotation,_that.backgroundIndex,_that.isPaletteOpen,_that.stickers,_that.isSharing,_that.isSaving,_that.isShared,_that.notice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StoryPostArgs post,  List<StoryPostBackground> backgrounds,  StoryPostStickerStyle style,  double x,  double y,  double scale,  double rotation,  int backgroundIndex,  bool isPaletteOpen,  List<StorySticker> stickers,  bool isSharing,  bool isSaving,  bool isShared,  StoryEditNotice? notice)  $default,) {final _that = this;
switch (_that) {
case _StoryPostEditState():
return $default(_that.post,_that.backgrounds,_that.style,_that.x,_that.y,_that.scale,_that.rotation,_that.backgroundIndex,_that.isPaletteOpen,_that.stickers,_that.isSharing,_that.isSaving,_that.isShared,_that.notice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StoryPostArgs post,  List<StoryPostBackground> backgrounds,  StoryPostStickerStyle style,  double x,  double y,  double scale,  double rotation,  int backgroundIndex,  bool isPaletteOpen,  List<StorySticker> stickers,  bool isSharing,  bool isSaving,  bool isShared,  StoryEditNotice? notice)?  $default,) {final _that = this;
switch (_that) {
case _StoryPostEditState() when $default != null:
return $default(_that.post,_that.backgrounds,_that.style,_that.x,_that.y,_that.scale,_that.rotation,_that.backgroundIndex,_that.isPaletteOpen,_that.stickers,_that.isSharing,_that.isSaving,_that.isShared,_that.notice);case _:
  return null;

}
}

}

/// @nodoc


class _StoryPostEditState implements StoryPostEditState {
  const _StoryPostEditState({required this.post, required  List<StoryPostBackground> backgrounds, this.style = StoryPostStickerStyle.card, this.x = 0.5, this.y = StoryPostDimens.defaultY, this.scale = 1.0, this.rotation = StoryPostDimens.defaultTilt, this.backgroundIndex = 0, this.isPaletteOpen = false,  List<StorySticker> stickers = const [], this.isSharing = false, this.isSaving = false, this.isShared = false, this.notice}): _backgrounds = backgrounds,_stickers = stickers;
  

@override final  StoryPostArgs post;
/// The six backgrounds the palette tool offers; the first follows the post's picture once it is read.
 final  List<StoryPostBackground> _backgrounds;
/// The six backgrounds the palette tool offers; the first follows the post's picture once it is read.
@override List<StoryPostBackground> get backgrounds {
  if (_backgrounds is EqualUnmodifiableListView) return _backgrounds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_backgrounds);
}

@override@JsonKey() final  StoryPostStickerStyle style;
/// Where the post sticker sits (fractions of the screen), how big and how it is turned (degrees).
@override@JsonKey() final  double x;
@override@JsonKey() final  double y;
@override@JsonKey() final  double scale;
@override@JsonKey() final  double rotation;
@override@JsonKey() final  int backgroundIndex;
/// The swatches show where the hint was.
@override@JsonKey() final  bool isPaletteOpen;
/// The text on the story.
 final  List<StorySticker> _stickers;
/// The text on the story.
@override@JsonKey() List<StorySticker> get stickers {
  if (_stickers is EqualUnmodifiableListView) return _stickers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stickers);
}

@override@JsonKey() final  bool isSharing;
@override@JsonKey() final  bool isSaving;
/// One-shot: the story was handed to the upload; the screen goes back to Home.
@override@JsonKey() final  bool isShared;
/// One-shot message for the screen.
@override final  StoryEditNotice? notice;

/// Create a copy of StoryPostEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryPostEditStateCopyWith<_StoryPostEditState> get copyWith => __$StoryPostEditStateCopyWithImpl<_StoryPostEditState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryPostEditState&&(identical(other.post, post) || other.post == post)&&const DeepCollectionEquality().equals(other.backgrounds, _backgrounds)&&(identical(other.style, style) || other.style == style)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.backgroundIndex, backgroundIndex) || other.backgroundIndex == backgroundIndex)&&(identical(other.isPaletteOpen, isPaletteOpen) || other.isPaletteOpen == isPaletteOpen)&&const DeepCollectionEquality().equals(other.stickers, _stickers)&&(identical(other.isSharing, isSharing) || other.isSharing == isSharing)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isShared, isShared) || other.isShared == isShared)&&(identical(other.notice, notice) || other.notice == notice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,post,const DeepCollectionEquality().hash(_backgrounds),style,x,y,scale,rotation,backgroundIndex,isPaletteOpen,const DeepCollectionEquality().hash(_stickers),isSharing,isSaving,isShared,notice);
}

@override
String toString() {
    return 'StoryPostEditState(post: $post, backgrounds: $backgrounds, style: $style, x: $x, y: $y, scale: $scale, rotation: $rotation, backgroundIndex: $backgroundIndex, isPaletteOpen: $isPaletteOpen, stickers: $stickers, isSharing: $isSharing, isSaving: $isSaving, isShared: $isShared, notice: $notice)';
}


}

/// @nodoc
abstract mixin class _$StoryPostEditStateCopyWith<$Res> implements $StoryPostEditStateCopyWith<$Res> {
  factory _$StoryPostEditStateCopyWith(_StoryPostEditState value, $Res Function(_StoryPostEditState) _then) = __$StoryPostEditStateCopyWithImpl;
@override @useResult
$Res call({
 StoryPostArgs post, List<StoryPostBackground> backgrounds, StoryPostStickerStyle style, double x, double y, double scale, double rotation, int backgroundIndex, bool isPaletteOpen, List<StorySticker> stickers, bool isSharing, bool isSaving, bool isShared, StoryEditNotice? notice
});




}
/// @nodoc
class __$StoryPostEditStateCopyWithImpl<$Res>
    implements _$StoryPostEditStateCopyWith<$Res> {
  __$StoryPostEditStateCopyWithImpl(this._self, this._then);

  final _StoryPostEditState _self;
  final $Res Function(_StoryPostEditState) _then;

/// Create a copy of StoryPostEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? post = null,Object? backgrounds = null,Object? style = null,Object? x = null,Object? y = null,Object? scale = null,Object? rotation = null,Object? backgroundIndex = null,Object? isPaletteOpen = null,Object? stickers = null,Object? isSharing = null,Object? isSaving = null,Object? isShared = null,Object? notice = freezed,}) {
  return _then(_StoryPostEditState(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as StoryPostArgs,backgrounds: null == backgrounds ? _self._backgrounds : backgrounds // ignore: cast_nullable_to_non_nullable
as List<StoryPostBackground>,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as StoryPostStickerStyle,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,backgroundIndex: null == backgroundIndex ? _self.backgroundIndex : backgroundIndex // ignore: cast_nullable_to_non_nullable
as int,isPaletteOpen: null == isPaletteOpen ? _self.isPaletteOpen : isPaletteOpen // ignore: cast_nullable_to_non_nullable
as bool,stickers: null == stickers ? _self._stickers : stickers // ignore: cast_nullable_to_non_nullable
as List<StorySticker>,isSharing: null == isSharing ? _self.isSharing : isSharing // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isShared: null == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as StoryEditNotice?,
  ));
}


}

// dart format on
