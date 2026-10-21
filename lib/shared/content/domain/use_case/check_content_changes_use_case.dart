import 'package:injectable/injectable.dart';

import '../../data/enums/content_kind.dart';
import '../../data/repository/content_changes_repository.dart';

/// Asks what changed in posts, shorts or stories since the last check. The answer arrives as a
/// `ContentChanged` event on the bus, so a screen that holds items of that kind listens for it. Quiet
/// when offline. Call it when Home opens and when the app comes back.
@injectable
class CheckContentChangesUseCase {
  CheckContentChangesUseCase(this._changes);

  final ContentChangesRepository _changes;

  Future<void> call(ContentKind kind) => _changes.check(kind);
}
