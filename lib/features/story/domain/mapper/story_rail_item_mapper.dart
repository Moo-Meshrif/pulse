import '../../data/model/story_rail_item_model.dart';
import '../entity/story_rail_item_entity.dart';

abstract final class StoryRailItemMapper {
  /// The people that can be drawn on the rail; a row without an id or username is left out.
  static List<StoryRailItemEntity> fromModels(List<StoryRailItemModel> items) =>
      [
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

  /// The rows again, for the copy kept on the device.
  static List<StoryRailItemModel> toModels(List<StoryRailItemEntity> items) => [
    for (final item in items)
      StoryRailItemModel(
        authorId: item.authorId,
        username: item.username,
        fullName: item.fullName,
        avatarUrl: item.avatarUrl,
        isMe: item.isMe,
        storyCount: item.storyCount,
        latestAt: item.latestAt,
        allSeen: item.allSeen,
      ),
  ];
}
