// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag_in_photo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TagInPhotoState {

/// The photos only: a video takes no spot.
 List<TagPhoto> get photos;/// The people chosen on Tag in photo's way in, with the spots set so far.
 List<TagChoice> get chosen;/// The photo on screen, an index into [photos].
 int get selected;/// Where the person tapped, as fractions of the photo, while the pick list is open.
 double? get pendingX; double? get pendingY;
/// Create a copy of TagInPhotoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagInPhotoStateCopyWith<TagInPhotoState> get copyWith => _$TagInPhotoStateCopyWithImpl<TagInPhotoState>(this as TagInPhotoState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TagInPhotoState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagInPhotoState&&const DeepCollectionEquality().equals(other.photos, _this.photos)&&const DeepCollectionEquality().equals(other.chosen, _this.chosen)&&(identical(other.selected, _this.selected) || other.selected == _this.selected)&&(identical(other.pendingX, _this.pendingX) || other.pendingX == _this.pendingX)&&(identical(other.pendingY, _this.pendingY) || other.pendingY == _this.pendingY));
}


@override
int get hashCode {
  final _this = this as TagInPhotoState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.photos),const DeepCollectionEquality().hash(_this.chosen),_this.selected,_this.pendingX,_this.pendingY);
}

@override
String toString() {
  final _this = this as TagInPhotoState;
  return 'TagInPhotoState(photos: ${_this.photos}, chosen: ${_this.chosen}, selected: ${_this.selected}, pendingX: ${_this.pendingX}, pendingY: ${_this.pendingY})';
}


}

/// @nodoc
abstract mixin class $TagInPhotoStateCopyWith<$Res>  {
  factory $TagInPhotoStateCopyWith(TagInPhotoState value, $Res Function(TagInPhotoState) _then) = _$TagInPhotoStateCopyWithImpl;
@useResult
$Res call({
 List<TagPhoto> photos, List<TagChoice> chosen, int selected, double? pendingX, double? pendingY
});




}
/// @nodoc
class _$TagInPhotoStateCopyWithImpl<$Res>
    implements $TagInPhotoStateCopyWith<$Res> {
  _$TagInPhotoStateCopyWithImpl(this._self, this._then);

  final TagInPhotoState _self;
  final $Res Function(TagInPhotoState) _then;

/// Create a copy of TagInPhotoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? photos = null,Object? chosen = null,Object? selected = null,Object? pendingX = freezed,Object? pendingY = freezed,}) {
  return _then(TagInPhotoState(
photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<TagPhoto>,chosen: null == chosen ? _self.chosen : chosen // ignore: cast_nullable_to_non_nullable
as List<TagChoice>,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as int,pendingX: freezed == pendingX ? _self.pendingX : pendingX // ignore: cast_nullable_to_non_nullable
as double?,pendingY: freezed == pendingY ? _self.pendingY : pendingY // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [TagInPhotoState].
extension TagInPhotoStatePatterns on TagInPhotoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagInPhotoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagInPhotoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagInPhotoState value)  $default,){
final _that = this;
switch (_that) {
case _TagInPhotoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagInPhotoState value)?  $default,){
final _that = this;
switch (_that) {
case _TagInPhotoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TagPhoto> photos,  List<TagChoice> chosen,  int selected,  double? pendingX,  double? pendingY)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagInPhotoState() when $default != null:
return $default(_that.photos,_that.chosen,_that.selected,_that.pendingX,_that.pendingY);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TagPhoto> photos,  List<TagChoice> chosen,  int selected,  double? pendingX,  double? pendingY)  $default,) {final _that = this;
switch (_that) {
case _TagInPhotoState():
return $default(_that.photos,_that.chosen,_that.selected,_that.pendingX,_that.pendingY);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TagPhoto> photos,  List<TagChoice> chosen,  int selected,  double? pendingX,  double? pendingY)?  $default,) {final _that = this;
switch (_that) {
case _TagInPhotoState() when $default != null:
return $default(_that.photos,_that.chosen,_that.selected,_that.pendingX,_that.pendingY);case _:
  return null;

}
}

}

/// @nodoc


class _TagInPhotoState extends TagInPhotoState {
  const _TagInPhotoState({required  List<TagPhoto> photos, required  List<TagChoice> chosen, this.selected = 0, this.pendingX, this.pendingY}): _photos = photos,_chosen = chosen,super._();
  

/// The photos only: a video takes no spot.
 final  List<TagPhoto> _photos;
/// The photos only: a video takes no spot.
@override List<TagPhoto> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

/// The people chosen on Tag in photo's way in, with the spots set so far.
 final  List<TagChoice> _chosen;
/// The people chosen on Tag in photo's way in, with the spots set so far.
@override List<TagChoice> get chosen {
  if (_chosen is EqualUnmodifiableListView) return _chosen;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chosen);
}

/// The photo on screen, an index into [photos].
@override@JsonKey() final  int selected;
/// Where the person tapped, as fractions of the photo, while the pick list is open.
@override final  double? pendingX;
@override final  double? pendingY;

/// Create a copy of TagInPhotoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagInPhotoStateCopyWith<_TagInPhotoState> get copyWith => __$TagInPhotoStateCopyWithImpl<_TagInPhotoState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagInPhotoState&&const DeepCollectionEquality().equals(other.photos, _photos)&&const DeepCollectionEquality().equals(other.chosen, _chosen)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.pendingX, pendingX) || other.pendingX == pendingX)&&(identical(other.pendingY, pendingY) || other.pendingY == pendingY));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_photos),const DeepCollectionEquality().hash(_chosen),selected,pendingX,pendingY);
}

@override
String toString() {
    return 'TagInPhotoState(photos: $photos, chosen: $chosen, selected: $selected, pendingX: $pendingX, pendingY: $pendingY)';
}


}

/// @nodoc
abstract mixin class _$TagInPhotoStateCopyWith<$Res> implements $TagInPhotoStateCopyWith<$Res> {
  factory _$TagInPhotoStateCopyWith(_TagInPhotoState value, $Res Function(_TagInPhotoState) _then) = __$TagInPhotoStateCopyWithImpl;
@override @useResult
$Res call({
 List<TagPhoto> photos, List<TagChoice> chosen, int selected, double? pendingX, double? pendingY
});




}
/// @nodoc
class __$TagInPhotoStateCopyWithImpl<$Res>
    implements _$TagInPhotoStateCopyWith<$Res> {
  __$TagInPhotoStateCopyWithImpl(this._self, this._then);

  final _TagInPhotoState _self;
  final $Res Function(_TagInPhotoState) _then;

/// Create a copy of TagInPhotoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? photos = null,Object? chosen = null,Object? selected = null,Object? pendingX = freezed,Object? pendingY = freezed,}) {
  return _then(_TagInPhotoState(
photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<TagPhoto>,chosen: null == chosen ? _self._chosen : chosen // ignore: cast_nullable_to_non_nullable
as List<TagChoice>,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as int,pendingX: freezed == pendingX ? _self.pendingX : pendingX // ignore: cast_nullable_to_non_nullable
as double?,pendingY: freezed == pendingY ? _self.pendingY : pendingY // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
