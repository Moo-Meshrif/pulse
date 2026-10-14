import 'package:injectable/injectable.dart';

import '../../data/datasource/post_actions_datasource.dart';

/// Likes or unlikes a post and returns its like count afterwards, to reconcile an optimistic update.
@injectable
class SetPostLikeUseCase {
  SetPostLikeUseCase(this._actions);

  final PostActionsDatasource _actions;

  Future<int> call(String postId, {required bool liked}) =>
      _actions.setLike(postId, liked: liked);
}
