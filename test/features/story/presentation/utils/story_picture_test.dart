import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/model/story_model.dart';
import 'package:pulse/features/story/presentation/utils/story_picture.dart';

void main() {
  const photo = StoryModel(
    id: 's1',
    type: StoryMediaType.image,
    path: 'u1/stories/a.jpg',
    mediaUrl: 'https://x.test/a.jpg?token=one',
  );
  const video = StoryModel(
    id: 's2',
    type: StoryMediaType.video,
    path: 'u1/stories/b.mp4',
    thumbPath: 'u1/stories/b_thumb.jpg',
    mediaUrl: 'https://x.test/b.mp4?token=one',
    thumbUrl: 'https://x.test/b_thumb.jpg?token=one',
  );

  test('a photo is the picture, cached under its storage path', () {
    final picture = storyPicture(photo)!;
    expect(picture.url, photo.mediaUrl);
    expect(picture.cacheKey, 'u1/stories/a.jpg');
  });

  test('a video shows, and caches, its poster frame', () {
    final picture = storyPicture(video)!;
    expect(picture.url, video.thumbUrl);
    expect(picture.cacheKey, 'u1/stories/b_thumb.jpg');
  });

  test('a new signed link gives the same cache key: no second download', () {
    final refetched = photo.withUrls(
      mediaUrl: 'https://x.test/a.jpg?token=two',
    );
    expect(storyPicture(refetched)!.url, isNot(storyPicture(photo)!.url));
    expect(storyPicture(refetched)!.cacheKey, storyPicture(photo)!.cacheKey);
  });

  test('no link, no picture', () {
    expect(storyPicture(const StoryModel(id: 's3', path: 'p')), isNull);
    expect(
      storyPicture(
        const StoryModel(id: 's4', type: StoryMediaType.video, mediaUrl: 'm'),
      ),
      isNull,
    );
  });
}
