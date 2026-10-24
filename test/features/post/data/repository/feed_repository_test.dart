import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/data/datasource/feed_local_datasource.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/data/model/feed_page_model.dart';
import 'package:pulse/features/post/data/model/post_model.dart';
import 'package:pulse/features/post/data/repository/feed_repository.dart';

import '../../../../helpers/memory_snapshot_storage.dart';

class _MockPosts extends Mock implements PostsDatasource {}

void main() {
  late _MockPosts posts;
  late MemorySnapshotStorage storage;
  late FeedRepositoryImpl repository;
  var userId = 'me';

  final page = FeedPageModel(
    posts: [PostModel(id: 'p1', createdAt: DateTime.utc(2026, 10, 13))],
    nextBeforeCreated: DateTime.utc(2026, 10, 13),
    nextBeforeId: 'p1',
  );

  setUp(() {
    userId = 'me';
    posts = _MockPosts();
    storage = MemorySnapshotStorage();
    repository = FeedRepositoryImpl(posts, FeedLocalDatasource(storage));
    when(() => posts.currentUserId).thenAnswer((_) => userId);
    when(
      () => posts.getHomeFeed(
        limit: any(named: 'limit'),
        beforeCreated: any(named: 'beforeCreated'),
        beforeId: any(named: 'beforeId'),
      ),
    ).thenAnswer((_) async => page);
  });

  test('the first page is saved with its cursor', () async {
    await repository.page(limit: 20);

    final saved = await repository.page(limit: 20, saved: true);
    expect(saved, page);
  });

  test('the saved JSON has no signed link', () async {
    await repository.page(limit: 20);

    expect(storage.values['feed_me'], isNot(contains('token')));
  });

  test('a later page is not saved', () async {
    await repository.page(
      limit: 20,
      beforeCreated: DateTime.utc(2026, 10, 12),
      beforeId: 'p0',
    );

    expect(storage.values, isEmpty);
  });

  test('saved: true asks no one and keeps one copy per user', () async {
    await repository.page(limit: 20);
    userId = 'other';

    final saved = await repository.page(limit: 20, saved: true);

    expect(saved.posts, isEmpty);
    verify(
      () => posts.getHomeFeed(
        limit: any(named: 'limit'),
        beforeCreated: any(named: 'beforeCreated'),
        beforeId: any(named: 'beforeId'),
      ),
    ).called(1);
  });

  test('nothing saved, or no session, is an empty page', () async {
    expect((await repository.page(limit: 20, saved: true)).posts, isEmpty);

    when(() => posts.currentUserId).thenThrow(const NetworkFailure());
    expect((await repository.page(limit: 20, saved: true)).posts, isEmpty);
  });

  test('a failed request throws and leaves the copy as it was', () async {
    await repository.page(limit: 20);
    when(
      () => posts.getHomeFeed(
        limit: any(named: 'limit'),
        beforeCreated: any(named: 'beforeCreated'),
        beforeId: any(named: 'beforeId'),
      ),
    ).thenThrow(const NetworkFailure());

    await expectLater(
      repository.page(limit: 20),
      throwsA(isA<NetworkFailure>()),
    );
    expect(await repository.page(limit: 20, saved: true), page);
  });

  test('a copy that cannot be read is an empty page', () async {
    storage.values['feed_me'] = 'not json';

    expect((await repository.page(limit: 20, saved: true)).posts, isEmpty);
  });
}
