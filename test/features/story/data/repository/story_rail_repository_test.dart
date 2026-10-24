import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/datasource/story_rail_local_datasource.dart';
import 'package:pulse/features/story/data/model/story_rail_item_model.dart';
import 'package:pulse/features/story/data/repository/story_rail_repository.dart';

import '../../../../helpers/memory_snapshot_storage.dart';

class _MockStories extends Mock implements StoriesDatasource {}

void main() {
  late _MockStories stories;
  late StoryRailRepositoryImpl repository;

  final items = [
    StoryRailItemModel(
      authorId: 'a1',
      username: 'nour',
      fullName: 'Nour',
      avatarUrl: 'https://cdn/a.jpg',
      isMe: false,
      storyCount: 2,
      latestAt: DateTime.utc(2026, 10, 13),
      allSeen: true,
    ),
  ];

  setUp(() {
    stories = _MockStories();
    repository = StoryRailRepositoryImpl(
      stories,
      StoryRailLocalDatasource(MemorySnapshotStorage()),
    );
    when(() => stories.currentUserId).thenReturn('me');
    when(() => stories.getStoryRail()).thenAnswer((_) async => items);
  });

  test(
    'the rail from the server is saved and read back with no request',
    () async {
      expect(await repository.rail(), items);

      expect(await repository.rail(saved: true), items);
      verify(() => stories.getStoryRail()).called(1);
    },
  );

  test('nothing saved, or no session, is no rail', () async {
    expect(await repository.rail(saved: true), isNull);

    when(() => stories.currentUserId).thenThrow(const NetworkFailure());
    expect(await repository.rail(saved: true), isNull);
  });

  test('a saved rail with no one on it is saved as empty', () async {
    when(() => stories.getStoryRail()).thenAnswer((_) async => const []);
    await repository.rail();
    await Future<void>.delayed(Duration.zero);

    expect(await repository.rail(saved: true), isEmpty);
  });
}
