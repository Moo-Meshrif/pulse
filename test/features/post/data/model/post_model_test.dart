import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/data/enums/media_type.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/data/model/feed_page_model.dart';
import 'package:pulse/features/post/data/model/post_media_model.dart';
import 'package:pulse/features/post/data/model/post_model.dart';
import 'package:pulse/features/post/data/model/post_tag_model.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

void main() {
  final original = PostModel(
    id: 'o1',
    authorId: 'a2',
    username: 'sara',
    createdAt: DateTime.utc(2026, 10, 12),
    media: const [
      PostMediaModel(
        position: 0,
        type: MediaType.image,
        path: 'a2/o1/0.jpg',
        width: 10,
        height: 20,
        blurhash: 'LEHV6n',
      ),
    ],
  );

  final post = PostModel(
    id: 'p1',
    authorId: 'a1',
    username: 'nour',
    fullName: 'Nour A',
    avatarUrl: 'https://cdn/avatar.jpg',
    caption: 'hello',
    location: 'Cairo',
    likeCount: 3,
    commentCount: 1,
    commentsEnabled: true,
    visibility: ContentAudience.public,
    createdAt: DateTime.utc(2026, 10, 13, 8, 30),
    likedByMe: true,
    savedByMe: false,
    media: const [
      PostMediaModel(
        position: 0,
        type: MediaType.image,
        path: 'a1/p1/0.jpg',
        width: 100,
        height: 80,
        blurhash: 'LEHV6n',
      ),
      PostMediaModel(
        position: 1,
        type: MediaType.video,
        path: 'a1/p1/1.mp4',
        thumbPath: 'a1/p1/1.jpg',
        width: 100,
        height: 80,
        durationMs: 4000,
      ),
    ],
    moodKind: MoodKind.feeling,
    moodKey: 'happy',
    moodText: 'Happy',
    tagCount: 1,
    tags: const [
      PostTagModel(
        userId: 'u9',
        username: 'omar',
        fullName: 'Omar K',
        mediaPosition: 0,
        x: 0.25,
        y: 0.5,
      ),
    ],
    iAmTagged: false,
    isShare: true,
    sharedPostId: 'o1',
    sharedPost: original,
  );

  test('a post saved as JSON reads back the same, with media, tags and a shared post', () {
    expect(PostModel.fromJson(post.toJson()), post);
  });

  test('a feed page reads back the same, with its cursor', () {
    final page = FeedPageModel(
      posts: [post],
      nextBeforeCreated: DateTime.utc(2026, 10, 13),
      nextBeforeId: 'p1',
    );

    expect(FeedPageModel.fromJson(page.toJson()), page);
  });

  test('the saved JSON holds storage paths and no signed link', () {
    final json = post.toJson().toString();

    expect(json, contains('a1/p1/0.jpg'));
    expect(json, isNot(contains('token=')));
    expect(json, isNot(contains('signed')));
  });
}
