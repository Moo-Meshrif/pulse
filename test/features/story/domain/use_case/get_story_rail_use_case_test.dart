import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/story/data/model/story_rail_item_model.dart';
import 'package:pulse/features/story/data/repository/story_rail_repository.dart';
import 'package:pulse/features/story/domain/entity/story_rail_item_entity.dart';
import 'package:pulse/features/story/domain/use_case/get_story_rail_use_case.dart';

class _MockStories extends Mock implements StoryRailRepository {}

void main() {
  late _MockStories stories;

  setUp(() => stories = _MockStories());

  test(
    'maps rows to entities and drops rows without an author or a name',
    () async {
      when(() => stories.rail()).thenAnswer(
        (_) async => [
          StoryRailItemModel(
            authorId: 'a1',
            username: 'nour',
            fullName: 'Nour',
            isMe: false,
            storyCount: 2,
            latestAt: DateTime.utc(2026, 10, 13),
            allSeen: true,
          ),
          const StoryRailItemModel(username: 'no-id'),
          const StoryRailItemModel(authorId: 'a3'),
          const StoryRailItemModel(authorId: 'a4', username: 'bare'),
        ],
      );

      final rail = await GetStoryRailUseCase(stories)();

      expect(rail, [
        StoryRailItemEntity(
          authorId: 'a1',
          username: 'nour',
          fullName: 'Nour',
          isMe: false,
          storyCount: 2,
          latestAt: DateTime.utc(2026, 10, 13),
          allSeen: true,
        ),
        const StoryRailItemEntity(
          authorId: 'a4',
          username: 'bare',
          isMe: false,
          storyCount: 0,
          allSeen: false,
        ),
      ]);
    },
  );
}
