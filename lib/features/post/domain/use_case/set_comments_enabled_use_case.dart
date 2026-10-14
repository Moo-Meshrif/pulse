import 'package:injectable/injectable.dart';

import '../../data/datasource/post_actions_datasource.dart';

/// Turns comments on or off for the signed-in user's post.
@injectable
class SetCommentsEnabledUseCase {
  SetCommentsEnabledUseCase(this._actions);

  final PostActionsDatasource _actions;

  Future<void> call(String postId, {required bool enabled}) =>
      _actions.setCommentsEnabled(postId, enabled: enabled);
}
