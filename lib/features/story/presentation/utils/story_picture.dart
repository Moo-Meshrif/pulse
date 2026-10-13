import 'package:flutter/widgets.dart';

import '../../../../core/utils/cached_picture.dart';
import '../../data/enums/story_media_type.dart';
import '../../data/model/story_model.dart';

/// The picture a story shows first: the photo itself, or a video's poster frame, as the link to load and the
/// key to cache it under (its storage path: the signed link changes every time, the path never does).
/// Null when the story has no picture to show. Shown with `AppImage.network(url, cacheKey: key)`.
({String url, String? cacheKey})? storyPicture(StoryModel story) {
  final isVideo = story.type == StoryMediaType.video;
  final url = isVideo ? story.thumbUrl : story.mediaUrl;
  if (url == null) return null;
  return (url: url, cacheKey: isVideo ? story.thumbPath : story.path);
}

/// Loads [story]'s picture in the background, so it is ready when the story comes up.
Future<void> preloadStoryPicture(BuildContext context, StoryModel story) {
  final picture = storyPicture(story);
  if (picture == null) return Future.value();
  return preloadPicture(
    context,
    cachedPicture(picture.url, cacheKey: picture.cacheKey),
  );
}

/// Forgets [story]'s cached picture (Retry after it failed to load).
Future<void> forgetStoryPicture(StoryModel story) {
  final picture = storyPicture(story);
  if (picture == null) return Future.value();
  return forgetPicture(picture.url, cacheKey: picture.cacheKey);
}
