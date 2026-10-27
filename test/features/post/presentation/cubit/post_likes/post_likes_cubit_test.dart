import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/state/load_more_status.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/post/domain/entity/post_liker_entity.dart';
import 'package:pulse/features/post/domain/entity/post_likers_cursor_entity.dart';
import 'package:pulse/features/post/domain/entity/post_likers_page_entity.dart';
import 'package:pulse/features/post/presentation/cubit/post_likes/post_likes_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/post_likes_status.dart';
import 'package:pulse/features/profile/domain/use_case/get_current_user_id_use_case.dart';

import '../../../post_doubles.dart';

class _Toggle extends Mock implements ToggleFollowUseCase {}

class _CurrentUser extends Mock implements GetCurrentUserIdUseCase {}

PostLikerEntity liker(
  String id, {
  FollowStatus follow = FollowStatus.none,
  bool followsMe = false,
}) => PostLikerEntity(
  id: id,
  username: id,
  likedAt: DateTime.utc(2026, 10, 27),
  follow: follow,
  followsMe: followsMe,
);

PostLikersPageEntity page(
  List<PostLikerEntity> likers, {
  int? total,
  PostLikersCursorEntity? next,
}) => PostLikersPageEntity(likers: likers, total: total, nextCursor: next);

void main() {
  late MockPostRepository posts;
  late _Toggle toggle;
  late PostLikesCubit cubit;
  final cursor = PostLikersCursorEntity(
    likedAt: DateTime.utc(2026, 10, 27),
    id: 'a',
  );

  setUpAll(() => registerFallbackValue(cursor));

  setUp(() {
    posts = MockPostRepository();
    toggle = _Toggle();
    final user = _CurrentUser();
    when(user.call).thenReturn('me');
    cubit = PostLikesCubit(posts, toggle, user, 'p1');
  });

  tearDown(() => cubit.close());

  void stubFirst(PostLikersPageEntity result, {String? query}) =>
      when(() => posts.likers('p1', query: query, before: null))
          .thenAnswer((_) async => result);

  test('load shows the people and the total', () async {
    stubFirst(page([liker('a')], total: 1204, next: cursor));
    await cubit.load();
    expect(cubit.state.status, PostLikesStatus.ready);
    expect(cubit.state.likers.single.id, 'a');
    expect(cubit.state.total, 1204);
    expect(cubit.state.nextCursor, cursor);
  });

  test('a failed first load is the failed status', () async {
    when(() => posts.likers('p1', query: null, before: null))
        .thenThrow(const NetworkFailure());
    await cubit.load();
    expect(cubit.state.status, PostLikesStatus.failed);
  });

  test('loadMore adds the next page and skips people already shown', () async {
    stubFirst(page([liker('a'), liker('b')], total: 3, next: cursor));
    await cubit.load();
    when(() => posts.likers('p1', query: null, before: cursor))
        .thenAnswer((_) async => page([liker('b'), liker('c')]));
    await cubit.loadMore();
    expect(cubit.state.likers.map((l) => l.id), ['a', 'b', 'c']);
    expect(cubit.state.nextCursor, isNull);
    expect(cubit.state.more, LoadMoreStatus.idle);
  });

  test('a failed page waits for retry', () async {
    stubFirst(page([liker('a')], next: cursor));
    await cubit.load();
    when(() => posts.likers('p1', query: null, before: cursor))
        .thenThrow(const NetworkFailure());
    await cubit.loadMore();
    expect(cubit.state.more, LoadMoreStatus.failed);
    await cubit.loadMore();
    verify(() => posts.likers('p1', query: null, before: cursor)).called(1);
    when(() => posts.likers('p1', query: null, before: cursor))
        .thenAnswer((_) async => page([liker('b')]));
    await cubit.loadMore(retry: true);
    expect(cubit.state.likers.length, 2);
  });

  test('search asks once after a pause and keeps the total', () {
    fakeAsync((async) {
      stubFirst(page([liker('a')], total: 50));
      cubit.load();
      async.flushMicrotasks();
      stubFirst(page([liker('sara')], total: 1), query: 'sa');
      cubit
        ..queryChanged('s')
        ..queryChanged('sa');
      async.elapse(const Duration(milliseconds: 299));
      verifyNever(() => posts.likers('p1', query: 'sa', before: null));
      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();
      verify(() => posts.likers('p1', query: 'sa', before: null)).called(1);
      expect(cubit.state.likers.single.id, 'sara');
      expect(cubit.state.total, 50);
    });
  });

  test('follow answers at once and takes the server status', () async {
    stubFirst(page([liker('a')]));
    await cubit.load();
    when(() => toggle('a', follow: true))
        .thenAnswer((_) async => FollowStatus.pending);
    final future = cubit.toggleFollow(cubit.state.likers.single);
    expect(cubit.state.likers.single.follow, FollowStatus.accepted);
    await future;
    expect(cubit.state.likers.single.follow, FollowStatus.pending);
  });

  test('unfollow needs no confirm', () async {
    stubFirst(page([liker('a', follow: FollowStatus.accepted)]));
    await cubit.load();
    when(() => toggle('a', follow: false))
        .thenAnswer((_) async => FollowStatus.none);
    await cubit.toggleFollow(cubit.state.likers.single);
    expect(cubit.state.likers.single.follow, FollowStatus.none);
  });

  test('a failed follow is put back and reported', () async {
    stubFirst(page([liker('a')]));
    await cubit.load();
    when(() => toggle('a', follow: true)).thenThrow(const NetworkFailure());
    await cubit.toggleFollow(cubit.state.likers.single);
    expect(cubit.state.likers.single.follow, FollowStatus.none);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test('your own row has no follow', () async {
    stubFirst(page([liker('me')]));
    await cubit.load();
    await cubit.toggleFollow(cubit.state.likers.single);
    verifyNever(() => toggle(any(), follow: any(named: 'follow')));
  });
}
