import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/domain/use_case/get_follow_status_use_case.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/post/domain/event/post_counts_changed.dart';
import 'package:pulse/features/post/domain/event/post_saved.dart';
import 'package:pulse/features/post/domain/use_case/get_liked_by_preview_use_case.dart';
import 'package:pulse/features/post/domain/use_case/get_post_use_case.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/post_page/post_page_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/post_page_status.dart';
import 'package:pulse/features/post/presentation/utils/feed_post.dart';
import 'package:pulse/features/profile/domain/use_case/get_current_user_id_use_case.dart';

import '../../../post_fixtures.dart';

class _LikedBy extends Mock implements GetLikedByPreviewUseCase {}

class _GetPost extends Mock implements GetPostUseCase {}

class _Sign extends Mock implements SignPostMediaUrlsUseCase {}

class _GetFollow extends Mock implements GetFollowStatusUseCase {}

class _Toggle extends Mock implements ToggleFollowUseCase {}

class _CurrentUser extends Mock implements GetCurrentUserIdUseCase {}

void main() {
  late _GetPost getPost;
  late _Sign sign;
  late _GetFollow getFollow;
  late _Toggle toggle;
  late _CurrentUser currentUser;
  late _LikedBy likedBy;
  late EventBus bus;

  setUp(() {
    getPost = _GetPost();
    sign = _Sign();
    getFollow = _GetFollow();
    toggle = _Toggle();
    currentUser = _CurrentUser();
    likedBy = _LikedBy();
    when(() => likedBy(any())).thenAnswer((_) async => null);
    bus = EventBus();
    when(currentUser.call).thenReturn('me');
    when(() => sign(any())).thenAnswer((_) async => {});
    when(() => getFollow(any())).thenAnswer((_) async => FollowStatus.none);
  });

  PostPageCubit build({FeedPost? passed}) => PostPageCubit(
    getPost,
    sign,
    getFollow,
    toggle,
    likedBy,
    bus,
    currentUser,
    'p1',
    passed,
  );

  FeedPost passedPost() =>
      FeedPost(entity: testPost('p1', likes: 1), media: const []);

  test('starts loading when no post is passed', () {
    final cubit = build();
    expect(cubit.state.status, PostPageStatus.loading);
    expect(cubit.state.post, isNull);
    expect(cubit.state.userId, 'me');
    cubit.close();
  });

  test('shows the passed post at once, then the fresh one', () async {
    when(() => getPost('p1')).thenAnswer((_) async => testPost('p1', likes: 7));
    final cubit = build(passed: passedPost());
    expect(cubit.state.status, PostPageStatus.ready);
    expect(cubit.state.post!.entity.likeCount, 1);

    await cubit.load();

    expect(cubit.state.status, PostPageStatus.ready);
    expect(cubit.state.post!.entity.likeCount, 7);
    await cubit.close();
  });

  test(
    'a post nobody can see is unavailable, also over a passed one',
    () async {
      when(() => getPost('p1')).thenAnswer((_) async => null);
      final cubit = build(passed: passedPost());

      await cubit.load();

      expect(cubit.state.status, PostPageStatus.unavailable);
      expect(cubit.state.post, isNull);
      await cubit.close();
    },
  );

  test('a failed load with nothing to show fails, and retry works', () async {
    when(() => getPost('p1')).thenThrow(const NetworkFailure());
    final cubit = build();
    await cubit.load();
    expect(cubit.state.status, PostPageStatus.failed);

    when(() => getPost('p1')).thenAnswer((_) async => testPost('p1'));
    await cubit.load();
    expect(cubit.state.status, PostPageStatus.ready);
    await cubit.close();
  });

  test('a failed refresh keeps the passed post and reports it', () async {
    when(() => getPost('p1')).thenThrow(const NetworkFailure());
    final cubit = build(passed: passedPost());

    await cubit.load();

    expect(cubit.state.status, PostPageStatus.ready);
    expect(cubit.state.post, isNotNull);
    expect(cubit.state.failure, isA<NetworkFailure>());
    await cubit.close();
  });

  test('reads where your follow of the author stands', () async {
    when(() => getPost('p1')).thenAnswer((_) async => testPost('p1'));
    when(() => getFollow('author'))
        .thenAnswer((_) async => FollowStatus.accepted);
    final cubit = build();

    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.follow, FollowStatus.accepted);
    await cubit.close();
  });

  test('your own post asks nothing about following', () async {
    when(() => getPost('p1'))
        .thenAnswer((_) async => testPost('p1', authorId: 'me'));
    final cubit = build();

    await cubit.load();

    verifyNever(() => getFollow(any()));
    expect(cubit.state.follow, isNull);
    await cubit.close();
  });

  group('follow', () {
    Future<PostPageCubit> loaded() async {
      when(() => getPost('p1')).thenAnswer((_) async => testPost('p1'));
      final cubit = build();
      await cubit.load();
      await Future<void>.delayed(Duration.zero);
      return cubit;
    }

    test('follows at once and keeps the server answer', () async {
      final cubit = await loaded();
      when(() => toggle('author', follow: true))
          .thenAnswer((_) async => FollowStatus.pending);

      final future = cubit.toggleFollow();
      expect(cubit.state.follow, FollowStatus.accepted);
      await future;

      expect(cubit.state.follow, FollowStatus.pending);
      await cubit.close();
    });

    test('unfollows when you follow', () async {
      final cubit = await loaded();
      when(() => toggle('author', follow: true))
          .thenAnswer((_) async => FollowStatus.accepted);
      await cubit.toggleFollow();
      when(() => toggle('author', follow: false))
          .thenAnswer((_) async => FollowStatus.none);

      await cubit.toggleFollow();

      expect(cubit.state.follow, FollowStatus.none);
      await cubit.close();
    });

    test('a failure puts the chip back and reports it', () async {
      final cubit = await loaded();
      when(() => toggle('author', follow: true))
          .thenThrow(const NetworkFailure());

      await cubit.toggleFollow();

      expect(cubit.state.follow, FollowStatus.none);
      expect(cubit.state.failure, isA<NetworkFailure>());
      await cubit.close();
    });
  });

  test('tells the feed the counts the page changed', () async {
    final cubit = build(passed: passedPost());
    final events = <PostCountsChanged>[];
    bus.on<PostCountsChanged>().listen(events.add);

    cubit.countsChanged(testPost('p1', likes: 11, liked: true, saved: true));
    await Future<void>.delayed(Duration.zero);

    expect(events.single.postId, 'p1');
    expect(events.single.likeCount, 11);
    expect(events.single.likedByMe, isTrue);
    expect(events.single.savedByMe, isTrue);
    await cubit.close();
  });

  test('reads the post again when it was edited', () async {
    when(() => getPost('p1')).thenAnswer((_) async => testPost('p1', likes: 2));
    final cubit = build(passed: passedPost());

    bus.fire(PostSaved(testPost('p2')));
    await Future<void>.delayed(Duration.zero);
    verifyNever(() => getPost(any()));

    bus.fire(PostSaved(testPost('p1')));
    await Future<void>.delayed(Duration.zero);
    verify(() => getPost('p1')).called(1);
    expect(cubit.state.post!.entity.likeCount, 2);
    await cubit.close();
  });
}
