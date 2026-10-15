import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/data/enums/media_type.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/data/model/feed_page_model.dart';
import 'package:pulse/features/post/data/model/post_media_model.dart';
import 'package:pulse/features/post/data/model/post_model.dart';
import 'package:pulse/features/post/data/model/post_tag_model.dart';
import 'package:pulse/features/post/domain/entity/feed_cursor_entity.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
import 'package:pulse/features/post/domain/use_case/get_home_feed_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

class _MockPosts extends Mock implements PostsDatasource {}

void main() {
  late _MockPosts posts;
  late GetHomeFeedUseCase useCase;
  final createdAt = DateTime.utc(2026, 10, 13, 10);

  setUp(() {
    posts = _MockPosts();
    useCase = GetHomeFeedUseCase(posts);
  });

  void answer(FeedPageModel page) => when(
    () => posts.getHomeFeed(
      limit: any(named: 'limit'),
      beforeCreated: any(named: 'beforeCreated'),
      beforeId: any(named: 'beforeId'),
    ),
  ).thenAnswer((_) async => page);

  test('maps the rows, filling defaults, and passes the cursor on', () async {
    answer(
      FeedPageModel(
        posts: [
          PostModel(
            id: 'p1',
            authorId: 'a1',
            username: 'dip',
            createdAt: createdAt,
            media: const [
              PostMediaModel(
                type: MediaType.image,
                path: 'a1/p1/0.jpg',
                width: 10,
                height: 20,
              ),
            ],
          ),
        ],
        nextBeforeCreated: createdAt,
        nextBeforeId: 'p1',
      ),
    );

    final page = await useCase(
      cursor: FeedCursorEntity(createdAt: createdAt, id: 'p0'),
    );

    verify(
      () => posts.getHomeFeed(
        limit: 20,
        beforeCreated: createdAt,
        beforeId: 'p0',
      ),
    );
    final post = page.posts.single;
    expect(post.likeCount, 0);
    expect(post.commentsEnabled, isTrue);
    expect(post.visibility, ContentAudience.public);
    expect(post.likedByMe, isFalse);
    expect(post.media.single.isVideo, isFalse);
    expect(page.nextCursor, FeedCursorEntity(createdAt: createdAt, id: 'p1'));
  });

  test('leaves out rows and media that miss what the card needs', () async {
    answer(
      FeedPageModel(
        posts: [
          const PostModel(id: 'p1'),
          PostModel(
            id: 'p2',
            authorId: 'a1',
            username: 'dip',
            createdAt: createdAt,
            media: const [PostMediaModel(path: 'a1/p2/0.jpg')],
          ),
        ],
      ),
    );

    final page = await useCase();

    expect(page.posts.map((p) => p.id), ['p2']);
    expect(page.posts.single.media, isEmpty);
    expect(page.nextCursor, isNull);
  });

  test('maps the mood and the tags, and drops what is incomplete', () async {
    answer(
      FeedPageModel(
        posts: [
          PostModel(
            id: 'p1',
            authorId: 'a1',
            username: 'dip',
            createdAt: createdAt,
            moodKind: MoodKind.feeling,
            moodKey: 'happy',
            tagCount: 4,
            iAmTagged: true,
            tags: const [
              PostTagModel(userId: 'u2', username: 'sara', mediaPosition: 0),
              PostTagModel(userId: 'u3'),
            ],
          ),
          PostModel(
            id: 'p2',
            authorId: 'a1',
            username: 'dip',
            createdAt: createdAt,
            moodKind: MoodKind.feeling,
          ),
        ],
      ),
    );

    final page = await useCase();

    final tagged = page.posts.first;
    expect(
      tagged.mood,
      const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'),
    );
    expect(tagged.tags, const [
      PostTagEntity(userId: 'u2', username: 'sara', mediaPosition: 0),
    ]);
    expect(tagged.tagCount, 4);
    expect(tagged.iAmTagged, isTrue);
    final plain = page.posts.last;
    expect(plain.mood, isNull);
    expect(plain.tags, isEmpty);
    expect(plain.tagCount, 0);
    expect(plain.iAmTagged, isFalse);
  });
}
