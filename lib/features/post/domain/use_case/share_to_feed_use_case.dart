import 'package:injectable/injectable.dart';

import '../../../../shared/content/data/enums/content_audience.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/data/repository/content_publish_repository.dart';
import '../../../../shared/content/domain/use_case/check_content_changes_use_case.dart';
import '../../data/datasource/posts_datasource.dart';
import '../../data/model/post_tag_model.dart';
import '../entity/post_mood_entity.dart';
import '../entity/post_tag_entity.dart';

/// Shares a Public post to your own feed with optional words, audience, feeling, place and tagged people. A
/// share of a share is made of its original. It goes out in the background, so Home's banner shows it like
/// a New post; returns false (nothing done) while three posts are already going out. When it is out, a change
/// check runs so the feed adds the new share on top, without loading again; a post that is gone or can't be
/// shared fails in the banner with a `NotFoundFailure`.
@injectable
class ShareToFeedUseCase {
  ShareToFeedUseCase(this._posts, this._publish, this._checkChanges);

  final PostsDatasource _posts;
  final ContentPublishRepository _publish;
  final CheckContentChangesUseCase _checkChanges;

  /// A null [audience] is your default one. Tags carry no photo spot: a share has no photo.
  bool call(
    String postId, {
    String? caption,
    ContentAudience? audience,
    PostMoodEntity? mood,
    String? location,
    List<PostTagEntity> tags = const [],
  }) => _publish.enqueue(
    kind: ContentKind.post,
    send: (_) async {
      await _posts.shareToFeed(
        postId: postId,
        caption: caption,
        audience: audience,
        moodKind: mood?.kind,
        moodKey: mood?.key,
        moodText: mood?.text,
        location: location,
        tags: [for (final tag in tags) PostTagModel(userId: tag.userId)],
      );
      // The new share arrives in the feed through the change check (the feed adds it on top).
      await _checkChanges(ContentKind.post);
    },
  );
}
