import 'package:injectable/injectable.dart';

import '../../data/datasource/stories_datasource.dart';
import '../entity/story_rail_item_entity.dart';

/// The people on the story rail: you first (with an active story), then unseen, then latest. The entry
/// point Home calls.
@injectable
class GetStoryRailUseCase {
  GetStoryRailUseCase(this._stories);

  final StoriesDatasource _stories;

  Future<List<StoryRailItemEntity>> call() async {
    final items = await _stories.getStoryRail();
    return [
      for (final item in items)
        if (item.authorId != null && item.username != null)
          StoryRailItemEntity(
            authorId: item.authorId!,
            username: item.username!,
            fullName: item.fullName,
            avatarUrl: item.avatarUrl,
            isMe: item.isMe ?? false,
            storyCount: item.storyCount ?? 0,
            latestAt: item.latestAt,
            allSeen: item.allSeen ?? false,
          ),
    ];
  }
}
