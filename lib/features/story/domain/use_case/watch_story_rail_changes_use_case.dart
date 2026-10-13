import 'package:injectable/injectable.dart';

import '../../data/datasource/stories_datasource.dart';

/// Fires when the people on your story rail changed (someone muted or unmuted, a story deleted). Home's rail
/// listens and reloads.
@injectable
class WatchStoryRailChangesUseCase {
  WatchStoryRailChangesUseCase(this._stories);

  final StoriesDatasource _stories;

  Stream<void> call() => _stories.railChanges;
}
