import 'package:flutter/painting.dart';

import 'story_rail_item_entity.dart';

/// What the rail hands the viewer when it opens (`/story/:authorId` route arguments): where on the screen
/// it was tapped, so it can grow from there, and who was tapped, so the loading screen can already show
/// them.
class StoryViewerArgs {
  const StoryViewerArgs({this.origin, this.person});

  final Offset? origin;
  final StoryRailItemEntity? person;
}
