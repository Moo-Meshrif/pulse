import '../../../../core/utils/app_video_controller.dart';
import 'post_card_data.dart';

/// Stable id of a post's video in the feed's player (post id and position).
String postVideoId(String postId, int index) => '$postId/$index';

/// Every video of [posts], in feed order, for [PostVideoScope.videos].
List<AppVideoItem> postVideos(List<PostCardData> posts) => [
  for (final post in posts)
    for (var i = 0; i < post.media.length; i++)
      if (post.media[i].isVideo && post.media[i].url != null)
        AppVideoItem(id: postVideoId(post.id, i), url: post.media[i].url!),
];
