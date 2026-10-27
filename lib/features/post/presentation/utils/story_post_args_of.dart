import '../../../../core/utils/story_post_args.dart';
import '../../domain/entity/post_entity.dart';
import 'feed_post.dart';

/// The post a story would show: its author, words and first picture (a video's poster). [post] is the
/// post on screen; a share's [target] is its original, which uses the links signed for it.
StoryPostArgs storyPostArgsOf(FeedPost post, PostEntity target) {
  final signed = post.entity.isShare ? post.originalMedia : post.media;
  final first = signed.firstOrNull;
  final isPoster = first != null && first.isVideo;
  return StoryPostArgs(
    postId: target.id,
    username: target.username,
    avatarUrl: target.avatarUrl,
    caption: target.caption,
    mediaUrl: isPoster ? first.posterUrl : first?.url,
    mediaCacheKey: isPoster ? first.posterCacheKey : first?.cacheKey,
    mediaAspect: first == null ? null : first.width / first.height,
  );
}
