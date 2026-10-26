// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comments_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommentsState {

 CommentsStatus get status; CommentSort get sort;/// Top-level comments in list order, each with the replies loaded so far.
 List<CommentEntity> get comments;/// Where the next page starts; null when there is none.
 CommentCursorEntity? get nextCursor; LoadMoreStatus get more;/// Threads (by top-level comment id) whose rest of replies is loading or failed.
 Map<String, LoadMoreStatus> get replies;/// Your comments that are being sent or failed, oldest first.
 List<PendingComment> get pending;/// The comment you are replying to (it may itself be a reply); null when writing a comment.
 CommentEntity? get replyTo;/// The comment of yours whose words are in the field to be changed; null when not editing.
 CommentEntity? get editing;/// One-shot: an emoji picked in the long-press menu, to put in the reply field.
 String? get emoji;/// How many comments this sheet added to the post, for the count on the card.
 int get countDelta;/// One-shot: an action did not go through (a like is put back).
 Failure? get failure;
/// Create a copy of CommentsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentsStateCopyWith<CommentsState> get copyWith => _$CommentsStateCopyWithImpl<CommentsState>(this as CommentsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommentsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentsState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.sort, _this.sort) || other.sort == _this.sort)&&const DeepCollectionEquality().equals(other.comments, _this.comments)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor)&&(identical(other.more, _this.more) || other.more == _this.more)&&const DeepCollectionEquality().equals(other.replies, _this.replies)&&const DeepCollectionEquality().equals(other.pending, _this.pending)&&(identical(other.replyTo, _this.replyTo) || other.replyTo == _this.replyTo)&&(identical(other.editing, _this.editing) || other.editing == _this.editing)&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji)&&(identical(other.countDelta, _this.countDelta) || other.countDelta == _this.countDelta)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as CommentsState;
  return Object.hash(runtimeType,_this.status,_this.sort,const DeepCollectionEquality().hash(_this.comments),_this.nextCursor,_this.more,const DeepCollectionEquality().hash(_this.replies),const DeepCollectionEquality().hash(_this.pending),_this.replyTo,_this.editing,_this.emoji,_this.countDelta,_this.failure);
}

@override
String toString() {
  final _this = this as CommentsState;
  return 'CommentsState(status: ${_this.status}, sort: ${_this.sort}, comments: ${_this.comments}, nextCursor: ${_this.nextCursor}, more: ${_this.more}, replies: ${_this.replies}, pending: ${_this.pending}, replyTo: ${_this.replyTo}, editing: ${_this.editing}, emoji: ${_this.emoji}, countDelta: ${_this.countDelta}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $CommentsStateCopyWith<$Res>  {
  factory $CommentsStateCopyWith(CommentsState value, $Res Function(CommentsState) _then) = _$CommentsStateCopyWithImpl;
@useResult
$Res call({
 CommentsStatus status, CommentSort sort, List<CommentEntity> comments, CommentCursorEntity? nextCursor, LoadMoreStatus more, Map<String, LoadMoreStatus> replies, List<PendingComment> pending, CommentEntity? replyTo, CommentEntity? editing, String? emoji, int countDelta, Failure? failure
});




}
/// @nodoc
class _$CommentsStateCopyWithImpl<$Res>
    implements $CommentsStateCopyWith<$Res> {
  _$CommentsStateCopyWithImpl(this._self, this._then);

  final CommentsState _self;
  final $Res Function(CommentsState) _then;

/// Create a copy of CommentsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? sort = null,Object? comments = null,Object? nextCursor = freezed,Object? more = null,Object? replies = null,Object? pending = null,Object? replyTo = freezed,Object? editing = freezed,Object? emoji = freezed,Object? countDelta = null,Object? failure = freezed,}) {
  return _then(CommentsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommentsStatus,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as CommentSort,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommentEntity>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as CommentCursorEntity?,more: null == more ? _self.more : more // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as Map<String, LoadMoreStatus>,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as List<PendingComment>,replyTo: freezed == replyTo ? _self.replyTo : replyTo // ignore: cast_nullable_to_non_nullable
as CommentEntity?,editing: freezed == editing ? _self.editing : editing // ignore: cast_nullable_to_non_nullable
as CommentEntity?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,countDelta: null == countDelta ? _self.countDelta : countDelta // ignore: cast_nullable_to_non_nullable
as int,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentsState].
extension CommentsStatePatterns on CommentsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentsState value)  $default,){
final _that = this;
switch (_that) {
case _CommentsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentsState value)?  $default,){
final _that = this;
switch (_that) {
case _CommentsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommentsStatus status,  CommentSort sort,  List<CommentEntity> comments,  CommentCursorEntity? nextCursor,  LoadMoreStatus more,  Map<String, LoadMoreStatus> replies,  List<PendingComment> pending,  CommentEntity? replyTo,  CommentEntity? editing,  String? emoji,  int countDelta,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentsState() when $default != null:
return $default(_that.status,_that.sort,_that.comments,_that.nextCursor,_that.more,_that.replies,_that.pending,_that.replyTo,_that.editing,_that.emoji,_that.countDelta,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommentsStatus status,  CommentSort sort,  List<CommentEntity> comments,  CommentCursorEntity? nextCursor,  LoadMoreStatus more,  Map<String, LoadMoreStatus> replies,  List<PendingComment> pending,  CommentEntity? replyTo,  CommentEntity? editing,  String? emoji,  int countDelta,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _CommentsState():
return $default(_that.status,_that.sort,_that.comments,_that.nextCursor,_that.more,_that.replies,_that.pending,_that.replyTo,_that.editing,_that.emoji,_that.countDelta,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommentsStatus status,  CommentSort sort,  List<CommentEntity> comments,  CommentCursorEntity? nextCursor,  LoadMoreStatus more,  Map<String, LoadMoreStatus> replies,  List<PendingComment> pending,  CommentEntity? replyTo,  CommentEntity? editing,  String? emoji,  int countDelta,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _CommentsState() when $default != null:
return $default(_that.status,_that.sort,_that.comments,_that.nextCursor,_that.more,_that.replies,_that.pending,_that.replyTo,_that.editing,_that.emoji,_that.countDelta,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _CommentsState implements CommentsState {
  const _CommentsState({this.status = CommentsStatus.loading, this.sort = CommentSort.relevant,  List<CommentEntity> comments = const <CommentEntity>[], this.nextCursor, this.more = LoadMoreStatus.idle,  Map<String, LoadMoreStatus> replies = const <String, LoadMoreStatus>{},  List<PendingComment> pending = const <PendingComment>[], this.replyTo, this.editing, this.emoji, this.countDelta = 0, this.failure}): _comments = comments,_replies = replies,_pending = pending;
  

@override@JsonKey() final  CommentsStatus status;
@override@JsonKey() final  CommentSort sort;
/// Top-level comments in list order, each with the replies loaded so far.
 final  List<CommentEntity> _comments;
/// Top-level comments in list order, each with the replies loaded so far.
@override@JsonKey() List<CommentEntity> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

/// Where the next page starts; null when there is none.
@override final  CommentCursorEntity? nextCursor;
@override@JsonKey() final  LoadMoreStatus more;
/// Threads (by top-level comment id) whose rest of replies is loading or failed.
 final  Map<String, LoadMoreStatus> _replies;
/// Threads (by top-level comment id) whose rest of replies is loading or failed.
@override@JsonKey() Map<String, LoadMoreStatus> get replies {
  if (_replies is EqualUnmodifiableMapView) return _replies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_replies);
}

/// Your comments that are being sent or failed, oldest first.
 final  List<PendingComment> _pending;
/// Your comments that are being sent or failed, oldest first.
@override@JsonKey() List<PendingComment> get pending {
  if (_pending is EqualUnmodifiableListView) return _pending;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pending);
}

/// The comment you are replying to (it may itself be a reply); null when writing a comment.
@override final  CommentEntity? replyTo;
/// The comment of yours whose words are in the field to be changed; null when not editing.
@override final  CommentEntity? editing;
/// One-shot: an emoji picked in the long-press menu, to put in the reply field.
@override final  String? emoji;
/// How many comments this sheet added to the post, for the count on the card.
@override@JsonKey() final  int countDelta;
/// One-shot: an action did not go through (a like is put back).
@override final  Failure? failure;

/// Create a copy of CommentsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentsStateCopyWith<_CommentsState> get copyWith => __$CommentsStateCopyWithImpl<_CommentsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentsState&&(identical(other.status, status) || other.status == status)&&(identical(other.sort, sort) || other.sort == sort)&&const DeepCollectionEquality().equals(other.comments, _comments)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.more, more) || other.more == more)&&const DeepCollectionEquality().equals(other.replies, _replies)&&const DeepCollectionEquality().equals(other.pending, _pending)&&(identical(other.replyTo, replyTo) || other.replyTo == replyTo)&&(identical(other.editing, editing) || other.editing == editing)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.countDelta, countDelta) || other.countDelta == countDelta)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,sort,const DeepCollectionEquality().hash(_comments),nextCursor,more,const DeepCollectionEquality().hash(_replies),const DeepCollectionEquality().hash(_pending),replyTo,editing,emoji,countDelta,failure);
}

@override
String toString() {
    return 'CommentsState(status: $status, sort: $sort, comments: $comments, nextCursor: $nextCursor, more: $more, replies: $replies, pending: $pending, replyTo: $replyTo, editing: $editing, emoji: $emoji, countDelta: $countDelta, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$CommentsStateCopyWith<$Res> implements $CommentsStateCopyWith<$Res> {
  factory _$CommentsStateCopyWith(_CommentsState value, $Res Function(_CommentsState) _then) = __$CommentsStateCopyWithImpl;
@override @useResult
$Res call({
 CommentsStatus status, CommentSort sort, List<CommentEntity> comments, CommentCursorEntity? nextCursor, LoadMoreStatus more, Map<String, LoadMoreStatus> replies, List<PendingComment> pending, CommentEntity? replyTo, CommentEntity? editing, String? emoji, int countDelta, Failure? failure
});




}
/// @nodoc
class __$CommentsStateCopyWithImpl<$Res>
    implements _$CommentsStateCopyWith<$Res> {
  __$CommentsStateCopyWithImpl(this._self, this._then);

  final _CommentsState _self;
  final $Res Function(_CommentsState) _then;

/// Create a copy of CommentsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? sort = null,Object? comments = null,Object? nextCursor = freezed,Object? more = null,Object? replies = null,Object? pending = null,Object? replyTo = freezed,Object? editing = freezed,Object? emoji = freezed,Object? countDelta = null,Object? failure = freezed,}) {
  return _then(_CommentsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommentsStatus,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as CommentSort,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommentEntity>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as CommentCursorEntity?,more: null == more ? _self.more : more // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,replies: null == replies ? _self._replies : replies // ignore: cast_nullable_to_non_nullable
as Map<String, LoadMoreStatus>,pending: null == pending ? _self._pending : pending // ignore: cast_nullable_to_non_nullable
as List<PendingComment>,replyTo: freezed == replyTo ? _self.replyTo : replyTo // ignore: cast_nullable_to_non_nullable
as CommentEntity?,editing: freezed == editing ? _self.editing : editing // ignore: cast_nullable_to_non_nullable
as CommentEntity?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,countDelta: null == countDelta ? _self.countDelta : countDelta // ignore: cast_nullable_to_non_nullable
as int,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
