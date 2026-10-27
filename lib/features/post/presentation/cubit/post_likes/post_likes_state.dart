import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../domain/entity/post_liker_entity.dart';
import '../../../domain/entity/post_likers_cursor_entity.dart';
import '../../utils/enums/post_likes_status.dart';

part 'post_likes_state.freezed.dart';

@freezed
abstract class PostLikesState with _$PostLikesState {
  const PostLikesState._();

  const factory PostLikesState({
    @Default(PostLikesStatus.loading) PostLikesStatus status,

    /// What is typed in the search field; blank shows everyone.
    @Default('') String query,
    @Default(<PostLikerEntity>[]) List<PostLikerEntity> likers,

    /// How many people the signed-in user may see on the post; null until the first page is in.
    int? total,

    /// Where the next page starts; null when there is none.
    PostLikersCursorEntity? nextCursor,
    @Default(LoadMoreStatus.idle) LoadMoreStatus more,

    /// A pull to refresh is running; the rows stay.
    @Default(false) bool isRefreshing,

    /// The signed-in user, who has no Follow button on their own row.
    String? userId,

    /// One-shot: a follow or a refresh did not go through (a follow is put back).
    Failure? failure,
  }) = _PostLikesState;

  bool get isSearching => query.trim().isNotEmpty;
}
