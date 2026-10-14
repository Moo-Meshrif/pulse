import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entity/post_entity.dart';
import '../utils/enums/post_row.dart';

part 'post_actions_state.freezed.dart';

/// What was done to the posts of a list since it was loaded, by post id. The list itself stays untouched;
/// a card shows the changed post when there is one.
@freezed
abstract class PostActionsState with _$PostActionsState {
  const factory PostActionsState({
    /// The post as changed by like, save, comments or audience; missing while nothing changed.
    @Default(<String, PostEntity>{}) Map<String, PostEntity> posts,

    /// A post's row; missing means [PostRow.card].
    @Default(<String, PostRow>{}) Map<String, PostRow> rows,

    /// One-shot: a like or save did not go through and was rolled back.
    Failure? failure,
  }) = _PostActionsState;
}
