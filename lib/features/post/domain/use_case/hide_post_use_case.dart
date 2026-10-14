import 'package:injectable/injectable.dart';

import '../../data/datasource/post_actions_datasource.dart';

/// Hides a post from the feed ("Not interested"); hidden false is Undo.
@injectable
class HidePostUseCase {
  HidePostUseCase(this._actions);

  final PostActionsDatasource _actions;

  Future<void> call(String postId, {required bool hidden}) =>
      _actions.hidePost(postId, hidden: hidden);
}
