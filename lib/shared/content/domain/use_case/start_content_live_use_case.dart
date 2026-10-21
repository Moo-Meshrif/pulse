import 'package:injectable/injectable.dart';

import '../../data/repository/content_changes_repository.dart';

/// Starts the live ping from the server (see `ContentPing`). Safe to call twice.
@injectable
class StartContentLiveUseCase {
  StartContentLiveUseCase(this._changes);

  final ContentChangesRepository _changes;

  void call() => _changes.startLive();
}
