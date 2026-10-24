import 'dart:async';

import 'package:injectable/injectable.dart';

import '../datasource/stories_datasource.dart';
import '../datasource/story_rail_local_datasource.dart';
import '../model/story_rail_item_model.dart';

/// The Stories rail from the server, kept on the device so Home can open with it next time.
abstract interface class StoryRailRepository {
  /// The rail from the server, also saved for the signed-in user. With [saved] no request is made: it
  /// returns the saved rail, null when nothing is saved or there is no session.
  Future<List<StoryRailItemModel>?> rail({bool saved = false});
}

@LazySingleton(as: StoryRailRepository)
class StoryRailRepositoryImpl implements StoryRailRepository {
  StoryRailRepositoryImpl(this._remote, this._local);

  final StoriesDatasource _remote;
  final StoryRailLocalDatasource _local;

  @override
  Future<List<StoryRailItemModel>?> rail({bool saved = false}) async {
    if (saved) return _savedRail();
    final items = await _remote.getStoryRail();
    _save(items);
    return items;
  }

  /// The rail is already on its way to the screen: it does not wait for the disk, and a copy that cannot be
  /// made (no session) never fails the load.
  void _save(List<StoryRailItemModel> items) {
    try {
      unawaited(_local.write(_remote.currentUserId, items));
    } on Object {
      return;
    }
  }

  List<StoryRailItemModel>? _savedRail() {
    final String userId;
    try {
      userId = _remote.currentUserId;
    } on Object {
      return null;
    }
    return _local.read(userId);
  }
}
