import '../../../../core/utils/app_video_controller.dart';
import '../../../post/presentation/utils/post_video_ids.dart';
import 'feed_post.dart';

/// Every video of the feed in order, for the list's `PostVideoScope`.
List<AppVideoItem> feedVideos(List<FeedPost> posts) => [
  for (final post in posts)
    for (var i = 0; i < post.media.length; i++)
      if (post.media[i].isVideo)
        AppVideoItem(id: postVideoId(post.id, i), url: post.media[i].url),
];
