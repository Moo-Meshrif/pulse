import 'package:injectable/injectable.dart';

import '../../data/repository/story_rail_repository.dart';
import '../entity/story_rail_item_entity.dart';
import '../mapper/story_rail_item_mapper.dart';

/// The people on the story rail: you first (with an active story), then unseen, then latest. The entry
/// point Home calls. [saved] returns the rail saved on the device, with no request.
@injectable
class GetStoryRailUseCase {
  GetStoryRailUseCase(this._rail);

  final StoryRailRepository _rail;

  Future<List<StoryRailItemEntity>> call() async =>
      StoryRailItemMapper.fromModels((await _rail.rail())!);

  /// Saves [items] as the rail on the device, no request.
  void save(List<StoryRailItemEntity> items) =>
      _rail.saveRail(StoryRailItemMapper.toModels(items));

  /// Null when nothing is saved; an empty list is a saved rail with no one on it.
  Future<List<StoryRailItemEntity>?> saved() async {
    final items = await _rail.rail(saved: true);
    return items == null ? null : StoryRailItemMapper.fromModels(items);
  }
}
