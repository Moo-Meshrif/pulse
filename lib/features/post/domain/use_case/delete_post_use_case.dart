import 'package:injectable/injectable.dart';

import '../../../../shared/content/data/datasource/media_files_datasource.dart';
import '../../data/datasource/post_actions_datasource.dart';

/// Deletes the signed-in user's post, then its files (best effort: a failed cleanup does not fail the
/// delete). The files are listed first, while the post still shows.
@injectable
class DeletePostUseCase {
  DeletePostUseCase(this._actions, this._files);

  final PostActionsDatasource _actions;
  final MediaFilesDatasource _files;

  Future<void> call(String postId) async {
    final paths = await _files.listFolder(postId);
    await _actions.deletePost(postId);
    await _files.remove(paths);
  }
}
