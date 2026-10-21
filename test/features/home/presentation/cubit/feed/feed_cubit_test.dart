import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/state/load_more_status.dart';
import 'package:pulse/features/home/presentation/cubit/feed/feed_cubit.dart';
import 'package:pulse/features/home/presentation/utils/enums/feed_status.dart';
import 'package:pulse/features/post/domain/entity/feed_cursor_entity.dart';
import 'package:pulse/features/post/domain/entity/feed_page_entity.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/event/feed_refresh_requested.dart';
import 'package:pulse/features/post/domain/event/post_saved.dart';
import 'package:pulse/features/post/domain/use_case/get_home_feed_use_case.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/get_current_user_id_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/domain/event/content_changed.dart';
import 'package:pulse/shared/content/domain/event/content_ping.dart';

import '../../../../post/post_fixtures.dart';
import '../../../home_doubles.dart';

class _GetFeed extends Mock implements GetHomeFeedUseCase {}

class _Sign extends Mock implements SignPostMediaUrlsUseCase {}

class _CurrentUser extends Mock implements GetCurrentUserIdUseCase {}

void main() {
  late _GetFeed getFeed;
  late _Sign sign;
  late _CurrentUser currentUser;
  late EventBus bus;
  late MockCheckContentChanges check;
  late MockGetPostsByIds postsByIds;
  late MockGetPostCounts counts;
  late MockStartContentLive startLive;
  late MockStopContentLive stopLive;

  final cursor = FeedCursorEntity(createdAt: DateTime(2026, 10, 13), id: 'p2');

  setUpAll(() => registerFallbackValue(cursor));

  setUp(() {
    getFeed = _GetFeed();
    sign = _Sign();
    currentUser = _CurrentUser();
    bus = EventBus();
    final changes = quietChangeDoubles();
    check = changes.check;
    postsByIds = changes.postsByIds;
    counts = changes.counts;
    startLive = changes.startLive;
    stopLive = changes.stopLive;
    when(currentUser.call).thenReturn('me');
    when(() => sign(any())).thenAnswer((_) async => {});
  });

  FeedCubit build() => FeedCubit(
    getFeed,
    sign,
    bus,
    currentUser,
    check,
    postsByIds,
    counts,
    startLive,
    stopLive,
  );

  void pages(FeedPageEntity first, [FeedPageEntity? second]) {
    when(() => getFeed(cursor: null)).thenAnswer((_) async => first);
    if (second != null) {
      when(() => getFeed(cursor: cursor)).thenAnswer((_) async => second);
    }
  }

  test('starts before loading, knows who is signed in', () {
    final cubit = build();
    expect(cubit.state.status, FeedStatus.initial);
    expect(cubit.state.userId, 'me');
  });

  group('load', () {
    test('shows the posts of the first page and its cursor', () async {
      pages(
        FeedPageEntity(
          posts: [testPost('p1'), testPost('p2')],
          nextCursor: cursor,
        ),
      );
      final cubit = build();
      final states = <FeedStatus>[];
      cubit.stream.listen((s) => states.add(s.status));
      await cubit.load();
      expect(states, [FeedStatus.loading, FeedStatus.ready]);
      expect(cubit.state.posts.map((p) => p.id), ['p1', 'p2']);
      expect(cubit.state.hasMore, isTrue);
      expect(cubit.state.generation, 1);
    });

    test('an empty feed is ready with no posts', () async {
      pages(const FeedPageEntity(posts: []));
      final cubit = build();
      await cubit.load();
      expect(cubit.state.status, FeedStatus.ready);
      expect(cubit.state.posts, isEmpty);
      expect(cubit.state.hasMore, isFalse);
    });

    test('signs every path once and turns files into card media', () async {
      pages(
        FeedPageEntity(
          posts: [
            testPost(
              'p1',
              media: [
                testMedia('a/1.jpg'),
                testMedia('a/2.mp4', thumbPath: 'a/2_thumb.jpg'),
                testMedia('a/3.jpg'),
              ],
            ),
          ],
        ),
      );
      when(() => sign(any())).thenAnswer(
        (_) async => {
          'a/1.jpg': 'u1',
          'a/2.mp4': 'u2',
          'a/2_thumb.jpg': 'u2t',
          // a/3.jpg could not be signed
        },
      );
      final cubit = build();
      await cubit.load();
      verify(() => sign(['a/1.jpg', 'a/2.mp4', 'a/2_thumb.jpg', 'a/3.jpg']))
          .called(1);
      final media = cubit.state.posts.single.media;
      expect(media.map((m) => m.url), ['u1', 'u2']);
      expect(media[1].isVideo, isTrue);
      expect(media[1].posterUrl, 'u2t');
      expect(media[1].cacheKey, 'a/2.mp4');
    });

    test('does not ask to sign when no post has media', () async {
      pages(FeedPageEntity(posts: [testPost('p1')]));
      await build().load();
      verifyNever(() => sign(any()));
    });

    test('a failure can be retried', () async {
      when(() => getFeed(cursor: null)).thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load();
      expect(cubit.state.status, FeedStatus.failed);
      expect(cubit.state.failure, const NetworkFailure());

      pages(FeedPageEntity(posts: [testPost('p1')]));
      await cubit.load();
      expect(cubit.state.status, FeedStatus.ready);
      expect(cubit.state.failure, isNull);
    });

    test('does nothing while loading or after it loaded', () async {
      pages(FeedPageEntity(posts: [testPost('p1')]));
      final cubit = build();
      await Future.wait([cubit.load(), cubit.load()]);
      await cubit.load();
      verify(() => getFeed(cursor: null)).called(1);
    });
  });

  group('refresh', () {
    test('keeps the posts on screen until the new ones arrive', () async {
      pages(FeedPageEntity(posts: [testPost('p1')]));
      final cubit = build();
      await cubit.load();

      pages(FeedPageEntity(posts: [testPost('p9'), testPost('p1')]));
      final refreshing = cubit.refresh();
      expect(cubit.state.isRefreshing, isTrue);
      expect(cubit.state.posts.map((p) => p.id), ['p1']);
      await refreshing;
      expect(cubit.state.isRefreshing, isFalse);
      expect(cubit.state.posts.map((p) => p.id), ['p9', 'p1']);
      expect(cubit.state.generation, 2);
    });

    test('a failure keeps the posts and says so once', () async {
      pages(FeedPageEntity(posts: [testPost('p1')]));
      final cubit = build();
      await cubit.load();

      when(() => getFeed(cursor: null)).thenThrow(const NetworkFailure());
      await cubit.refresh();
      expect(cubit.state.isRefreshing, isFalse);
      expect(cubit.state.posts, hasLength(1));
      expect(cubit.state.refreshFailure, const NetworkFailure());
      expect(cubit.state.generation, 1);
    });

    test('does nothing before the first load finished', () async {
      final cubit = build();
      await cubit.refresh();
      verifyNever(() => getFeed(cursor: any(named: 'cursor')));
    });
  });

  group('loadMore', () {
    test('adds the next page and skips posts already there', () async {
      pages(
        FeedPageEntity(
          posts: [testPost('p1'), testPost('p2')],
          nextCursor: cursor,
        ),
        FeedPageEntity(posts: [testPost('p2'), testPost('p3')]),
      );
      final cubit = build();
      await cubit.load();
      await cubit.loadMore();
      expect(cubit.state.posts.map((p) => p.id), ['p1', 'p2', 'p3']);
      expect(cubit.state.hasMore, isFalse);
      expect(cubit.state.loadMore, LoadMoreStatus.idle);
    });

    test('does nothing on the last page', () async {
      pages(FeedPageEntity(posts: [testPost('p1')]));
      final cubit = build();
      await cubit.load();
      await cubit.loadMore();
      verify(() => getFeed(cursor: null)).called(1);
      verifyNever(() => getFeed(cursor: cursor));
    });

    test('a failure keeps the posts and can be retried', () async {
      pages(FeedPageEntity(posts: [testPost('p1')], nextCursor: cursor));
      final cubit = build();
      await cubit.load();

      when(() => getFeed(cursor: cursor)).thenThrow(const NetworkFailure());
      await cubit.loadMore();
      expect(cubit.state.loadMore, LoadMoreStatus.failed);
      expect(cubit.state.posts, hasLength(1));
      expect(cubit.state.hasMore, isTrue);

      when(() => getFeed(cursor: cursor))
          .thenAnswer((_) async => FeedPageEntity(posts: [testPost('p2')]));
      await cubit.loadMore();
      expect(cubit.state.loadMore, LoadMoreStatus.idle);
      expect(cubit.state.posts.map((p) => p.id), ['p1', 'p2']);
    });

    test('asks for one page at a time', () async {
      pages(
        FeedPageEntity(posts: [testPost('p1')], nextCursor: cursor),
        FeedPageEntity(posts: [testPost('p2')]),
      );
      final cubit = build();
      await cubit.load();
      await Future.wait([cubit.loadMore(), cubit.loadMore()]);
      verify(() => getFeed(cursor: cursor)).called(1);
    });
  });

  group('start and refresh requests', () {
    test('loads, then refreshes whenever something asks', () async {
      pages(FeedPageEntity(posts: [testPost('p1')]));
      final cubit = build();
      await cubit.start();
      expect(cubit.state.status, FeedStatus.ready);

      pages(FeedPageEntity(posts: [testPost('p9'), testPost('p1')]));
      bus.fire(const FeedRefreshRequested());
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.posts.map((p) => p.id), ['p9', 'p1']);
      await cubit.close();
    });

    test('a feed that failed to load tries again', () async {
      when(() => getFeed(cursor: null)).thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.start();
      expect(cubit.state.status, FeedStatus.failed);

      pages(FeedPageEntity(posts: [testPost('p1')]));
      bus.fire(const FeedRefreshRequested());
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.status, FeedStatus.ready);
      await cubit.close();
    });

    test('a shared post goes first without loading again', () async {
      pages(FeedPageEntity(posts: [testPost('p1')]));
      final cubit = build();
      await cubit.start();

      bus.fire(PostSaved(testPost('p9')));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.posts.map((p) => p.id), ['p9', 'p1']);
      verify(() => getFeed(cursor: null)).called(1);
      await cubit.close();
    });

    test('an edited post is replaced where it is', () async {
      pages(FeedPageEntity(posts: [testPost('p1'), testPost('p2')]));
      final cubit = build();
      await cubit.start();

      bus.fire(PostSaved(testPost('p2')));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.posts.map((p) => p.id), ['p1', 'p2']);
      await cubit.close();
    });

    test('stops listening when closed', () async {
      pages(FeedPageEntity(posts: [testPost('p1')]));
      final cubit = build();
      await cubit.start();
      await cubit.close();
      bus.fire(const FeedRefreshRequested());
      await Future<void>.delayed(Duration.zero);
      verify(() => getFeed(cursor: null)).called(1);
    });
  });

  group('content changes', () {
    test('a changed post is replaced where it stands, an unreadable new one is not added', () async {
      pages(FeedPageEntity(posts: [testPost('p1'), testPost('p2')]));
      when(() => postsByIds(['p2', 'p7']))
          .thenAnswer((_) async => [testPost('p2', likes: 99)]);
      final cubit = build();
      await cubit.start();

      bus.fire(
        const ContentChanged(ContentKind.post, upsertedIds: ['p2', 'p7']),
      );
      await pumpEventQueue();

      expect(cubit.state.posts.map((p) => p.id), ['p1', 'p2']);
      expect(cubit.state.posts.last.entity.likeCount, 99);
      expect(cubit.state.replacedIds, {'p2'});
      await cubit.close();
    });

    test(
      'a deleted post leaves, and so does one that can no longer be read',
      () async {
        pages(
          FeedPageEntity(
            posts: [testPost('p1'), testPost('p2'), testPost('p3')],
          ),
        );
        when(() => postsByIds(['p2'])).thenAnswer((_) async => []);
        final cubit = build();
        await cubit.start();

        bus.fire(
          const ContentChanged(
            ContentKind.post,
            removedIds: ['p1', 'zz'],
            upsertedIds: ['p2'],
          ),
        );
        await pumpEventQueue();

        expect(cubit.state.posts.map((p) => p.id), ['p3']);
        await cubit.close();
      },
    );

    test('a changes event for stories is ignored', () async {
      pages(FeedPageEntity(posts: [testPost('p1')]));
      final cubit = build();
      await cubit.start();

      bus.fire(const ContentChanged(ContentKind.story, removedIds: ['p1']));
      await pumpEventQueue();

      expect(cubit.state.posts.map((p) => p.id), ['p1']);
      await cubit.close();
    });

    test('mustReload loads the feed again without the refresh band', () async {
      pages(FeedPageEntity(posts: [testPost('p1')]));
      final cubit = build();
      await cubit.start();
      final bands = <bool>[];
      cubit.stream.listen((s) => bands.add(s.isRefreshing));

      pages(FeedPageEntity(posts: [testPost('p9')]));
      bus.fire(const ContentChanged(ContentKind.post, mustReload: true));
      await pumpEventQueue();

      expect(cubit.state.posts.map((p) => p.id), ['p9']);
      expect(bands, everyElement(isFalse));
      await cubit.close();
    });

    test('mustReload is ignored while the feed is loading', () async {
      final first = Completer<FeedPageEntity>();
      when(() => getFeed(cursor: null)).thenAnswer((_) => first.future);
      final cubit = build();
      final started = cubit.start();

      bus.fire(const ContentChanged(ContentKind.post, mustReload: true));
      await pumpEventQueue();
      first.complete(FeedPageEntity(posts: [testPost('p1')]));
      await started;
      await pumpEventQueue();

      verify(() => getFeed(cursor: null)).called(1);
      await cubit.close();
    });
  });

  group('new posts', () {
    PostEntity newer(String id, {String author = 'other'}) => PostEntity(
      id: id,
      authorId: author,
      username: 'user_$author',
      likeCount: 0,
      commentCount: 0,
      commentsEnabled: true,
      visibility: ContentAudience.public,
      createdAt: DateTime(2026, 10, 20),
      likedByMe: false,
      savedByMe: false,
      media: const [],
    );

    Future<FeedCubit> started() async {
      pages(FeedPageEntity(posts: [testPost('p1'), testPost('p2')]));
      final cubit = build();
      await cubit.start();
      return cubit;
    }

    void fireNew(String id) {
      bus.fire(ContentChanged(ContentKind.post, upsertedIds: [id]));
    }

    test(
      "another person's new post waits and the feed does not move",
      () async {
        when(() => postsByIds(['p9'])).thenAnswer((_) async => [newer('p9')]);
        final cubit = await started();

        fireNew('p9');
        await pumpEventQueue();

        expect(cubit.state.posts.map((p) => p.id), ['p1', 'p2']);
        expect(cubit.state.pendingPosts.map((p) => p.id), ['p9']);
        await cubit.close();
      },
    );

    test(
      'showPending puts the waiting posts on top and marks them fresh',
      () async {
        when(() => postsByIds(['p9'])).thenAnswer((_) async => [newer('p9')]);
        final cubit = await started();
        fireNew('p9');
        await pumpEventQueue();

        cubit.showPending();

        expect(cubit.state.posts.map((p) => p.id), ['p9', 'p1', 'p2']);
        expect(cubit.state.pendingPosts, isEmpty);
        expect(cubit.state.freshIds, {'p9'});
        await cubit.close();
      },
    );

    test('my own new post goes on top at once', () async {
      when(() => postsByIds(['p9']))
          .thenAnswer((_) async => [newer('p9', author: 'me')]);
      final cubit = await started();

      fireNew('p9');
      await pumpEventQueue();

      expect(cubit.state.posts.map((p) => p.id), ['p9', 'p1', 'p2']);
      expect(cubit.state.pendingPosts, isEmpty);
      await cubit.close();
    });

    test('a waiting post that was deleted meanwhile is dropped', () async {
      when(() => postsByIds(['p9'])).thenAnswer((_) async => [newer('p9')]);
      final cubit = await started();
      fireNew('p9');
      await pumpEventQueue();

      bus.fire(const ContentChanged(ContentKind.post, removedIds: ['p9']));
      await pumpEventQueue();

      expect(cubit.state.pendingPosts, isEmpty);
      await cubit.close();
    });
  });

  test('a post ping runs the change check; a story ping does not', () async {
    final cubit = build();
    addTearDown(cubit.close);
    await cubit.start();
    clearInteractions(check);

    bus.fire(const ContentPing(ContentKind.story));
    bus.fire(const ContentPing(ContentKind.post));
    await Future<void>.delayed(Duration.zero);

    verify(() => check(ContentKind.post)).called(1);
    verifyNever(() => check(ContentKind.story));
  });

  test('live starts with the feed, pauses and stops with it', () async {
    final cubit = build();
    await cubit.start();
    verify(() => startLive()).called(1);

    cubit.pauseLive();
    verify(() => stopLive()).called(1);

    await cubit.close();
    verify(() => stopLive()).called(1);
  });
}
