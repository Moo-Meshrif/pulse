import 'package:injectable/injectable.dart';

import '../../data/datasource/content_actions_datasource.dart';
import '../../data/enums/mute_scope.dart';

/// Mutes a person for [MuteScope] (their posts leave your feed, or their stories leave your rail; you
/// still follow them) or brings them back; `muted: false` is Undo.
@injectable
class SetMuteUseCase {
  SetMuteUseCase(this._actions);

  final ContentActionsDatasource _actions;

  Future<void> call(
    String userId, {
    required bool muted,
    required MuteScope scope,
  }) => _actions.setMuted(userId, muted: muted, scope: scope);
}
