import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/story/data/model/story_viewer_model.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/presentation/cubit/story_viewers_cubit.dart';
import 'package:pulse/features/story/presentation/utils/enums/story_viewers_status.dart';

class _Viewers extends Mock implements StoriesDatasource {}

List<StoryViewerModel> page(int from, int count) => [
  for (var i = from; i < from + count; i++)
    StoryViewerModel(
      userId: 'u$i',
      viewedAt: DateTime(2026, 10, 13).subtract(Duration(minutes: i)),
      total: 45,
    ),
];

void main() {
  late _Viewers viewers;
  late StoryViewersCubit cubit;

  setUp(() {
    viewers = _Viewers();
    cubit = StoryViewersCubit(viewers);
    registerFallbackValue(DateTime(2026));
  });

  tearDown(() => cubit.close());

  test('loads the first page and takes the total from it', () async {
    when(() => viewers.getViewers('s1', limit: 30))
        .thenAnswer((_) async => page(0, 30));
    await cubit.load('s1', knownTotal: 3);
    expect(cubit.state.status, StoryViewersStatus.ready);
    expect(cubit.state.viewers, hasLength(30));
    expect(cubit.state.total, 45);
    expect(cubit.state.hasMore, isTrue);
  });

  test('a short first page has no more', () async {
    when(() => viewers.getViewers('s1', limit: 30))
        .thenAnswer((_) async => page(0, 2));
    await cubit.load('s1');
    expect(cubit.state.hasMore, isFalse);
    await cubit.loadMore();
    verify(() => viewers.getViewers('s1', limit: 30))
        .called(1); // only the first page was asked for
  });

  test('load more continues after the last viewer, newest first', () async {
    final first = page(0, 30);
    when(() => viewers.getViewers('s1', limit: 30))
        .thenAnswer((_) async => first);
    when(() => viewers.getViewers('s1', limit: 30, before: first.last.viewedAt))
        .thenAnswer((_) async => page(30, 15));
    await cubit.load('s1');
    await cubit.loadMore();
    expect(cubit.state.viewers, hasLength(45));
    expect(cubit.state.hasMore, isFalse);
    expect(cubit.state.isLoadingMore, isFalse);
  });

  test('a failed page keeps the list and can be tried again', () async {
    final first = page(0, 30);
    when(() => viewers.getViewers('s1', limit: 30))
        .thenAnswer((_) async => first);
    when(() => viewers.getViewers('s1', limit: 30, before: first.last.viewedAt))
        .thenThrow(const NetworkFailure());
    await cubit.load('s1');
    await cubit.loadMore();
    expect(cubit.state.viewers, hasLength(30));
    expect(cubit.state.loadMoreFailed, isTrue);

    when(() => viewers.getViewers('s1', limit: 30, before: first.last.viewedAt))
        .thenAnswer((_) async => page(30, 5));
    await cubit.loadMore();
    expect(cubit.state.viewers, hasLength(35));
    expect(cubit.state.loadMoreFailed, isFalse);
  });

  test('a failed first page is failed, and retry loads again', () async {
    when(() => viewers.getViewers('s1', limit: 30))
        .thenThrow(const NetworkFailure());
    await cubit.load('s1', knownTotal: 7);
    expect(cubit.state.status, StoryViewersStatus.failed);
    expect(cubit.state.total, 7);

    when(() => viewers.getViewers('s1', limit: 30))
        .thenAnswer((_) async => page(0, 3));
    await cubit.retry();
    expect(cubit.state.status, StoryViewersStatus.ready);
  });
}
