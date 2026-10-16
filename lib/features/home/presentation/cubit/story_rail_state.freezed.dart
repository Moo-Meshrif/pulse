// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_rail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoryRailState {

/// The people with an active story: you first when you have one, then unseen, then latest.
 List<StoryRailItemEntity> get items;/// How posting your own story is going.
 ContentPublishStatus get upload;
/// Create a copy of StoryRailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryRailStateCopyWith<StoryRailState> get copyWith => _$StoryRailStateCopyWithImpl<StoryRailState>(this as StoryRailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StoryRailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryRailState&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.upload, _this.upload) || other.upload == _this.upload));
}


@override
int get hashCode {
  final _this = this as StoryRailState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.upload);
}

@override
String toString() {
  final _this = this as StoryRailState;
  return 'StoryRailState(items: ${_this.items}, upload: ${_this.upload})';
}


}

/// @nodoc
abstract mixin class $StoryRailStateCopyWith<$Res>  {
  factory $StoryRailStateCopyWith(StoryRailState value, $Res Function(StoryRailState) _then) = _$StoryRailStateCopyWithImpl;
@useResult
$Res call({
 List<StoryRailItemEntity> items, ContentPublishStatus upload
});




}
/// @nodoc
class _$StoryRailStateCopyWithImpl<$Res>
    implements $StoryRailStateCopyWith<$Res> {
  _$StoryRailStateCopyWithImpl(this._self, this._then);

  final StoryRailState _self;
  final $Res Function(StoryRailState) _then;

/// Create a copy of StoryRailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? upload = null,}) {
  return _then(StoryRailState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<StoryRailItemEntity>,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as ContentPublishStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryRailState].
extension StoryRailStatePatterns on StoryRailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryRailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryRailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryRailState value)  $default,){
final _that = this;
switch (_that) {
case _StoryRailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryRailState value)?  $default,){
final _that = this;
switch (_that) {
case _StoryRailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<StoryRailItemEntity> items,  ContentPublishStatus upload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryRailState() when $default != null:
return $default(_that.items,_that.upload);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<StoryRailItemEntity> items,  ContentPublishStatus upload)  $default,) {final _that = this;
switch (_that) {
case _StoryRailState():
return $default(_that.items,_that.upload);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<StoryRailItemEntity> items,  ContentPublishStatus upload)?  $default,) {final _that = this;
switch (_that) {
case _StoryRailState() when $default != null:
return $default(_that.items,_that.upload);case _:
  return null;

}
}

}

/// @nodoc


class _StoryRailState extends StoryRailState {
  const _StoryRailState({ List<StoryRailItemEntity> items = const <StoryRailItemEntity>[], this.upload = const ContentPublishIdle(ContentKind.story)}): _items = items,super._();
  

/// The people with an active story: you first when you have one, then unseen, then latest.
 final  List<StoryRailItemEntity> _items;
/// The people with an active story: you first when you have one, then unseen, then latest.
@override@JsonKey() List<StoryRailItemEntity> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// How posting your own story is going.
@override@JsonKey() final  ContentPublishStatus upload;

/// Create a copy of StoryRailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryRailStateCopyWith<_StoryRailState> get copyWith => __$StoryRailStateCopyWithImpl<_StoryRailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryRailState&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.upload, upload) || other.upload == upload));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),upload);
}

@override
String toString() {
    return 'StoryRailState(items: $items, upload: $upload)';
}


}

/// @nodoc
abstract mixin class _$StoryRailStateCopyWith<$Res> implements $StoryRailStateCopyWith<$Res> {
  factory _$StoryRailStateCopyWith(_StoryRailState value, $Res Function(_StoryRailState) _then) = __$StoryRailStateCopyWithImpl;
@override @useResult
$Res call({
 List<StoryRailItemEntity> items, ContentPublishStatus upload
});




}
/// @nodoc
class __$StoryRailStateCopyWithImpl<$Res>
    implements _$StoryRailStateCopyWith<$Res> {
  __$StoryRailStateCopyWithImpl(this._self, this._then);

  final _StoryRailState _self;
  final $Res Function(_StoryRailState) _then;

/// Create a copy of StoryRailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? upload = null,}) {
  return _then(_StoryRailState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<StoryRailItemEntity>,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as ContentPublishStatus,
  ));
}


}

// dart format on
