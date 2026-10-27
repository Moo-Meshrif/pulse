import 'package:injectable/injectable.dart';

import '../../../follow/data/enums/follow_status.dart';
import '../../data/datasource/post_likes_datasource.dart';
import '../../data/model/post_liker_model.dart';
import '../entity/post_liker_entity.dart';
import '../entity/post_likers_cursor_entity.dart';
import '../entity/post_likers_page_entity.dart';

/// A page of the people who liked [postId] that the signed-in user may see, newest first; [query] narrows
/// it by name or username. Pass the previous page's `nextCursor` as [before] for the next one. A row
/// missing something the list needs is left out. Throws a `Failure` on error.
@injectable
class GetPostLikersUseCase {
  GetPostLikersUseCase(this._likes);

  final PostLikesDatasource _likes;

  static const pageSize = 20;

  Future<PostLikersPageEntity> call(
    String postId, {
    String? query,
    PostLikersCursorEntity? before,
  }) async {
    final page = await _likes.getLikers(
      postId,
      query: query,
      limit: pageSize,
      beforeLikedAt: before?.likedAt,
      beforeId: before?.id,
    );
    final nextAt = page.nextLikedAt;
    final nextId = page.nextId;
    return PostLikersPageEntity(
      likers: [for (final model in page.likers) ?_entity(model)],
      total: page.likers.firstOrNull?.total,
      nextCursor: nextAt == null || nextId == null
          ? null
          : PostLikersCursorEntity(likedAt: nextAt, id: nextId),
    );
  }

  PostLikerEntity? _entity(PostLikerModel model) {
    final id = model.id;
    final username = model.username;
    final likedAt = model.likedAt;
    if (id == null || username == null || likedAt == null) return null;
    return PostLikerEntity(
      id: id,
      username: username,
      fullName: model.fullName,
      avatarUrl: model.avatarUrl,
      likedAt: likedAt,
      follow: FollowStatus.fromJson(model.followStatus),
      followsMe: model.followsMe ?? false,
    );
  }
}
