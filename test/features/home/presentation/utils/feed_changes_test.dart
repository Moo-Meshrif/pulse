import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/home/presentation/utils/feed_changes.dart';
import 'package:pulse/features/home/presentation/utils/feed_post.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

FeedPost feedPost(String id, {String author = 'other', required int day}) =>
    FeedPost(
      entity: PostEntity(
        id: id,
        authorId: author,
        username: 'user_$author',
        likeCount: 0,
        commentCount: 0,
        commentsEnabled: true,
        visibility: ContentAudience.public,
        createdAt: DateTime.utc(2026, 10, day),
        likedByMe: false,
        savedByMe: false,
        media: const [],
      ),
      media: const [],
    );

List<String> ids(List<FeedPost> posts) => [for (final p in posts) p.id];

void main() {
  final feed = [feedPost('p2', day: 12), feedPost('p1', day: 10)];

  FeedChangeResult apply({
    List<FeedPost>? posts,
    List<FeedPost> pending = const [],
    required List<FeedPost> fresh,
    List<String>? asked,
  }) => applyFreshPosts(
    posts: posts ?? feed,
    pending: pending,
    fresh: fresh,
    asked: asked ?? [for (final p in fresh) p.id],
    userId: 'me',
  );

  group('applyFreshPosts', () {
    test("another person's new post waits and the feed does not move", () {
      final result = apply(fresh: [feedPost('p3', day: 14)]);

      expect(ids(result.posts), ['p2', 'p1']);
      expect(ids(result.pending), ['p3']);
      expect(result.freshIds, isEmpty);
    });

    test('my own new post goes on top at once and is marked fresh', () {
      final result = apply(fresh: [feedPost('p3', author: 'me', day: 14)]);

      expect(ids(result.posts), ['p3', 'p2', 'p1']);
      expect(result.pending, isEmpty);
      expect(result.freshIds, {'p3'});
    });

    test(
      'a post older than the newest one belongs deeper down and is ignored',
      () {
        final result = apply(fresh: [feedPost('old', day: 3)]);

        expect(ids(result.posts), ['p2', 'p1']);
        expect(result.pending, isEmpty);
      },
    );

    test('a post on the feed is replaced where it stands', () {
      final edited = feedPost('p1', day: 10);
      final result = apply(fresh: [edited]);

      expect(ids(result.posts), ['p2', 'p1']);
      expect(identical(result.posts.last, edited), isTrue);
      expect(result.replacedIds, {'p1'});
    });

    test(
      'a waiting post is replaced, or dropped when it can no longer be read',
      () {
        final waiting = [feedPost('p4', day: 15), feedPost('p3', day: 14)];
        final edited = feedPost('p3', day: 14);

        final result = apply(
          pending: waiting,
          fresh: [edited],
          asked: ['p3', 'p4'],
        );

        expect(ids(result.pending), ['p3']);
        expect(identical(result.pending.single, edited), isTrue);
      },
    );

    test('a post that can no longer be read leaves the feed', () {
      final result = apply(fresh: const [], asked: ['p1']);

      expect(ids(result.posts), ['p2']);
    });

    test('with an empty feed every new post counts', () {
      final result = apply(
        posts: const [],
        fresh: [feedPost('a', day: 1), feedPost('b', day: 2)],
      );

      expect(ids(result.pending), ['b', 'a']);
    });
  });

  test('withPendingOnTop puts the waiting posts first, each once', () {
    final merged = withPendingOnTop(feed, [
      feedPost('p3', day: 14),
      feedPost('p2', day: 12),
    ]);

    expect(ids(merged), ['p3', 'p2', 'p1']);
  });
}
