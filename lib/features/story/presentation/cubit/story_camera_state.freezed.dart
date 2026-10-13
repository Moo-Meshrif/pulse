// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_camera_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoryCameraState {

 StoryCameraStatus get status; CameraLens get lens; bool get hasFlash; bool get isFlashOn; bool get isRecording; Duration get elapsed;/// A photo or video is being saved (shutter released): further taps do nothing.
 bool get isBusy; bool get hintVisible;/// One-shot: a photo or video is ready for the edit screen; the screen takes it and clears it.
 CapturedStoryMedia? get captured;/// One-shot message for the screen.
 StoryCameraNotice? get notice;
/// Create a copy of StoryCameraState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryCameraStateCopyWith<StoryCameraState> get copyWith => _$StoryCameraStateCopyWithImpl<StoryCameraState>(this as StoryCameraState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StoryCameraState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryCameraState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.lens, _this.lens) || other.lens == _this.lens)&&(identical(other.hasFlash, _this.hasFlash) || other.hasFlash == _this.hasFlash)&&(identical(other.isFlashOn, _this.isFlashOn) || other.isFlashOn == _this.isFlashOn)&&(identical(other.isRecording, _this.isRecording) || other.isRecording == _this.isRecording)&&(identical(other.elapsed, _this.elapsed) || other.elapsed == _this.elapsed)&&(identical(other.isBusy, _this.isBusy) || other.isBusy == _this.isBusy)&&(identical(other.hintVisible, _this.hintVisible) || other.hintVisible == _this.hintVisible)&&(identical(other.captured, _this.captured) || other.captured == _this.captured)&&(identical(other.notice, _this.notice) || other.notice == _this.notice));
}


@override
int get hashCode {
  final _this = this as StoryCameraState;
  return Object.hash(runtimeType,_this.status,_this.lens,_this.hasFlash,_this.isFlashOn,_this.isRecording,_this.elapsed,_this.isBusy,_this.hintVisible,_this.captured,_this.notice);
}

@override
String toString() {
  final _this = this as StoryCameraState;
  return 'StoryCameraState(status: ${_this.status}, lens: ${_this.lens}, hasFlash: ${_this.hasFlash}, isFlashOn: ${_this.isFlashOn}, isRecording: ${_this.isRecording}, elapsed: ${_this.elapsed}, isBusy: ${_this.isBusy}, hintVisible: ${_this.hintVisible}, captured: ${_this.captured}, notice: ${_this.notice})';
}


}

/// @nodoc
abstract mixin class $StoryCameraStateCopyWith<$Res>  {
  factory $StoryCameraStateCopyWith(StoryCameraState value, $Res Function(StoryCameraState) _then) = _$StoryCameraStateCopyWithImpl;
@useResult
$Res call({
 StoryCameraStatus status, CameraLens lens, bool hasFlash, bool isFlashOn, bool isRecording, Duration elapsed, bool isBusy, bool hintVisible, CapturedStoryMedia? captured, StoryCameraNotice? notice
});




}
/// @nodoc
class _$StoryCameraStateCopyWithImpl<$Res>
    implements $StoryCameraStateCopyWith<$Res> {
  _$StoryCameraStateCopyWithImpl(this._self, this._then);

  final StoryCameraState _self;
  final $Res Function(StoryCameraState) _then;

/// Create a copy of StoryCameraState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? lens = null,Object? hasFlash = null,Object? isFlashOn = null,Object? isRecording = null,Object? elapsed = null,Object? isBusy = null,Object? hintVisible = null,Object? captured = freezed,Object? notice = freezed,}) {
  return _then(StoryCameraState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StoryCameraStatus,lens: null == lens ? _self.lens : lens // ignore: cast_nullable_to_non_nullable
as CameraLens,hasFlash: null == hasFlash ? _self.hasFlash : hasFlash // ignore: cast_nullable_to_non_nullable
as bool,isFlashOn: null == isFlashOn ? _self.isFlashOn : isFlashOn // ignore: cast_nullable_to_non_nullable
as bool,isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as Duration,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,hintVisible: null == hintVisible ? _self.hintVisible : hintVisible // ignore: cast_nullable_to_non_nullable
as bool,captured: freezed == captured ? _self.captured : captured // ignore: cast_nullable_to_non_nullable
as CapturedStoryMedia?,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as StoryCameraNotice?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryCameraState].
extension StoryCameraStatePatterns on StoryCameraState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryCameraState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryCameraState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryCameraState value)  $default,){
final _that = this;
switch (_that) {
case _StoryCameraState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryCameraState value)?  $default,){
final _that = this;
switch (_that) {
case _StoryCameraState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StoryCameraStatus status,  CameraLens lens,  bool hasFlash,  bool isFlashOn,  bool isRecording,  Duration elapsed,  bool isBusy,  bool hintVisible,  CapturedStoryMedia? captured,  StoryCameraNotice? notice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryCameraState() when $default != null:
return $default(_that.status,_that.lens,_that.hasFlash,_that.isFlashOn,_that.isRecording,_that.elapsed,_that.isBusy,_that.hintVisible,_that.captured,_that.notice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StoryCameraStatus status,  CameraLens lens,  bool hasFlash,  bool isFlashOn,  bool isRecording,  Duration elapsed,  bool isBusy,  bool hintVisible,  CapturedStoryMedia? captured,  StoryCameraNotice? notice)  $default,) {final _that = this;
switch (_that) {
case _StoryCameraState():
return $default(_that.status,_that.lens,_that.hasFlash,_that.isFlashOn,_that.isRecording,_that.elapsed,_that.isBusy,_that.hintVisible,_that.captured,_that.notice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StoryCameraStatus status,  CameraLens lens,  bool hasFlash,  bool isFlashOn,  bool isRecording,  Duration elapsed,  bool isBusy,  bool hintVisible,  CapturedStoryMedia? captured,  StoryCameraNotice? notice)?  $default,) {final _that = this;
switch (_that) {
case _StoryCameraState() when $default != null:
return $default(_that.status,_that.lens,_that.hasFlash,_that.isFlashOn,_that.isRecording,_that.elapsed,_that.isBusy,_that.hintVisible,_that.captured,_that.notice);case _:
  return null;

}
}

}

/// @nodoc


class _StoryCameraState extends StoryCameraState {
  const _StoryCameraState({this.status = StoryCameraStatus.idle, this.lens = CameraLens.back, this.hasFlash = false, this.isFlashOn = false, this.isRecording = false, this.elapsed = Duration.zero, this.isBusy = false, this.hintVisible = true, this.captured, this.notice}): super._();
  

@override@JsonKey() final  StoryCameraStatus status;
@override@JsonKey() final  CameraLens lens;
@override@JsonKey() final  bool hasFlash;
@override@JsonKey() final  bool isFlashOn;
@override@JsonKey() final  bool isRecording;
@override@JsonKey() final  Duration elapsed;
/// A photo or video is being saved (shutter released): further taps do nothing.
@override@JsonKey() final  bool isBusy;
@override@JsonKey() final  bool hintVisible;
/// One-shot: a photo or video is ready for the edit screen; the screen takes it and clears it.
@override final  CapturedStoryMedia? captured;
/// One-shot message for the screen.
@override final  StoryCameraNotice? notice;

/// Create a copy of StoryCameraState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryCameraStateCopyWith<_StoryCameraState> get copyWith => __$StoryCameraStateCopyWithImpl<_StoryCameraState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryCameraState&&(identical(other.status, status) || other.status == status)&&(identical(other.lens, lens) || other.lens == lens)&&(identical(other.hasFlash, hasFlash) || other.hasFlash == hasFlash)&&(identical(other.isFlashOn, isFlashOn) || other.isFlashOn == isFlashOn)&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.elapsed, elapsed) || other.elapsed == elapsed)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.hintVisible, hintVisible) || other.hintVisible == hintVisible)&&(identical(other.captured, captured) || other.captured == captured)&&(identical(other.notice, notice) || other.notice == notice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,lens,hasFlash,isFlashOn,isRecording,elapsed,isBusy,hintVisible,captured,notice);
}

@override
String toString() {
    return 'StoryCameraState(status: $status, lens: $lens, hasFlash: $hasFlash, isFlashOn: $isFlashOn, isRecording: $isRecording, elapsed: $elapsed, isBusy: $isBusy, hintVisible: $hintVisible, captured: $captured, notice: $notice)';
}


}

/// @nodoc
abstract mixin class _$StoryCameraStateCopyWith<$Res> implements $StoryCameraStateCopyWith<$Res> {
  factory _$StoryCameraStateCopyWith(_StoryCameraState value, $Res Function(_StoryCameraState) _then) = __$StoryCameraStateCopyWithImpl;
@override @useResult
$Res call({
 StoryCameraStatus status, CameraLens lens, bool hasFlash, bool isFlashOn, bool isRecording, Duration elapsed, bool isBusy, bool hintVisible, CapturedStoryMedia? captured, StoryCameraNotice? notice
});




}
/// @nodoc
class __$StoryCameraStateCopyWithImpl<$Res>
    implements _$StoryCameraStateCopyWith<$Res> {
  __$StoryCameraStateCopyWithImpl(this._self, this._then);

  final _StoryCameraState _self;
  final $Res Function(_StoryCameraState) _then;

/// Create a copy of StoryCameraState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? lens = null,Object? hasFlash = null,Object? isFlashOn = null,Object? isRecording = null,Object? elapsed = null,Object? isBusy = null,Object? hintVisible = null,Object? captured = freezed,Object? notice = freezed,}) {
  return _then(_StoryCameraState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StoryCameraStatus,lens: null == lens ? _self.lens : lens // ignore: cast_nullable_to_non_nullable
as CameraLens,hasFlash: null == hasFlash ? _self.hasFlash : hasFlash // ignore: cast_nullable_to_non_nullable
as bool,isFlashOn: null == isFlashOn ? _self.isFlashOn : isFlashOn // ignore: cast_nullable_to_non_nullable
as bool,isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as Duration,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,hintVisible: null == hintVisible ? _self.hintVisible : hintVisible // ignore: cast_nullable_to_non_nullable
as bool,captured: freezed == captured ? _self.captured : captured // ignore: cast_nullable_to_non_nullable
as CapturedStoryMedia?,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as StoryCameraNotice?,
  ));
}


}

// dart format on
