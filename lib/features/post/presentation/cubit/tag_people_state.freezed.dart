// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag_people_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TagPeopleState {

/// Who is being tagged, in the order they were picked.
 List<TagChoice> get chosen; String get query; TagPeopleStatus get status;/// The suggested people, or the matches for [query].
 List<TagPersonEntity> get people;/// One-shot: someone was picked while the post already has the most people.
 bool get isOverLimit;
/// Create a copy of TagPeopleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagPeopleStateCopyWith<TagPeopleState> get copyWith => _$TagPeopleStateCopyWithImpl<TagPeopleState>(this as TagPeopleState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TagPeopleState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagPeopleState&&const DeepCollectionEquality().equals(other.chosen, _this.chosen)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.people, _this.people)&&(identical(other.isOverLimit, _this.isOverLimit) || other.isOverLimit == _this.isOverLimit));
}


@override
int get hashCode {
  final _this = this as TagPeopleState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.chosen),_this.query,_this.status,const DeepCollectionEquality().hash(_this.people),_this.isOverLimit);
}

@override
String toString() {
  final _this = this as TagPeopleState;
  return 'TagPeopleState(chosen: ${_this.chosen}, query: ${_this.query}, status: ${_this.status}, people: ${_this.people}, isOverLimit: ${_this.isOverLimit})';
}


}

/// @nodoc
abstract mixin class $TagPeopleStateCopyWith<$Res>  {
  factory $TagPeopleStateCopyWith(TagPeopleState value, $Res Function(TagPeopleState) _then) = _$TagPeopleStateCopyWithImpl;
@useResult
$Res call({
 List<TagChoice> chosen, String query, TagPeopleStatus status, List<TagPersonEntity> people, bool isOverLimit
});




}
/// @nodoc
class _$TagPeopleStateCopyWithImpl<$Res>
    implements $TagPeopleStateCopyWith<$Res> {
  _$TagPeopleStateCopyWithImpl(this._self, this._then);

  final TagPeopleState _self;
  final $Res Function(TagPeopleState) _then;

/// Create a copy of TagPeopleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chosen = null,Object? query = null,Object? status = null,Object? people = null,Object? isOverLimit = null,}) {
  return _then(TagPeopleState(
chosen: null == chosen ? _self.chosen : chosen // ignore: cast_nullable_to_non_nullable
as List<TagChoice>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TagPeopleStatus,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as List<TagPersonEntity>,isOverLimit: null == isOverLimit ? _self.isOverLimit : isOverLimit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TagPeopleState].
extension TagPeopleStatePatterns on TagPeopleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagPeopleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagPeopleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagPeopleState value)  $default,){
final _that = this;
switch (_that) {
case _TagPeopleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagPeopleState value)?  $default,){
final _that = this;
switch (_that) {
case _TagPeopleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TagChoice> chosen,  String query,  TagPeopleStatus status,  List<TagPersonEntity> people,  bool isOverLimit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagPeopleState() when $default != null:
return $default(_that.chosen,_that.query,_that.status,_that.people,_that.isOverLimit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TagChoice> chosen,  String query,  TagPeopleStatus status,  List<TagPersonEntity> people,  bool isOverLimit)  $default,) {final _that = this;
switch (_that) {
case _TagPeopleState():
return $default(_that.chosen,_that.query,_that.status,_that.people,_that.isOverLimit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TagChoice> chosen,  String query,  TagPeopleStatus status,  List<TagPersonEntity> people,  bool isOverLimit)?  $default,) {final _that = this;
switch (_that) {
case _TagPeopleState() when $default != null:
return $default(_that.chosen,_that.query,_that.status,_that.people,_that.isOverLimit);case _:
  return null;

}
}

}

/// @nodoc


class _TagPeopleState extends TagPeopleState {
  const _TagPeopleState({required  List<TagChoice> chosen, this.query = '', this.status = TagPeopleStatus.loading,  List<TagPersonEntity> people = const <TagPersonEntity>[], this.isOverLimit = false}): _chosen = chosen,_people = people,super._();
  

/// Who is being tagged, in the order they were picked.
 final  List<TagChoice> _chosen;
/// Who is being tagged, in the order they were picked.
@override List<TagChoice> get chosen {
  if (_chosen is EqualUnmodifiableListView) return _chosen;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chosen);
}

@override@JsonKey() final  String query;
@override@JsonKey() final  TagPeopleStatus status;
/// The suggested people, or the matches for [query].
 final  List<TagPersonEntity> _people;
/// The suggested people, or the matches for [query].
@override@JsonKey() List<TagPersonEntity> get people {
  if (_people is EqualUnmodifiableListView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_people);
}

/// One-shot: someone was picked while the post already has the most people.
@override@JsonKey() final  bool isOverLimit;

/// Create a copy of TagPeopleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagPeopleStateCopyWith<_TagPeopleState> get copyWith => __$TagPeopleStateCopyWithImpl<_TagPeopleState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagPeopleState&&const DeepCollectionEquality().equals(other.chosen, _chosen)&&(identical(other.query, query) || other.query == query)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.people, _people)&&(identical(other.isOverLimit, isOverLimit) || other.isOverLimit == isOverLimit));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_chosen),query,status,const DeepCollectionEquality().hash(_people),isOverLimit);
}

@override
String toString() {
    return 'TagPeopleState(chosen: $chosen, query: $query, status: $status, people: $people, isOverLimit: $isOverLimit)';
}


}

/// @nodoc
abstract mixin class _$TagPeopleStateCopyWith<$Res> implements $TagPeopleStateCopyWith<$Res> {
  factory _$TagPeopleStateCopyWith(_TagPeopleState value, $Res Function(_TagPeopleState) _then) = __$TagPeopleStateCopyWithImpl;
@override @useResult
$Res call({
 List<TagChoice> chosen, String query, TagPeopleStatus status, List<TagPersonEntity> people, bool isOverLimit
});




}
/// @nodoc
class __$TagPeopleStateCopyWithImpl<$Res>
    implements _$TagPeopleStateCopyWith<$Res> {
  __$TagPeopleStateCopyWithImpl(this._self, this._then);

  final _TagPeopleState _self;
  final $Res Function(_TagPeopleState) _then;

/// Create a copy of TagPeopleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chosen = null,Object? query = null,Object? status = null,Object? people = null,Object? isOverLimit = null,}) {
  return _then(_TagPeopleState(
chosen: null == chosen ? _self._chosen : chosen // ignore: cast_nullable_to_non_nullable
as List<TagChoice>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TagPeopleStatus,people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as List<TagPersonEntity>,isOverLimit: null == isOverLimit ? _self.isOverLimit : isOverLimit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
