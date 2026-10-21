import 'package:injectable/injectable.dart';

import '../../data/repository/content_changes_repository.dart';

/// Stops the live ping from the server (see `ContentPing`). Safe to call twice.
@injectable
class StopContentLiveUseCase {
  StopContentLiveUseCase(this._changes);

  final ContentChangesRepository _changes;

  void call() => _changes.stopLive();
}
