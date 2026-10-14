import 'package:injectable/injectable.dart';

import '../../data/datasource/post_actions_datasource.dart';

/// Saves or unsaves a post and returns where the save stands afterwards.
@injectable
class SetPostSaveUseCase {
  SetPostSaveUseCase(this._actions);

  final PostActionsDatasource _actions;

  Future<bool> call(String postId, {required bool saved}) =>
      _actions.setSave(postId, saved: saved);
}
