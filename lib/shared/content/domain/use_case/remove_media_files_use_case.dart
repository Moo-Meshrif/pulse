import 'package:injectable/injectable.dart';

import '../../data/datasource/media_files_datasource.dart';

/// Removes the files of content that was deleted. Best effort: it never throws.
@injectable
class RemoveMediaFilesUseCase {
  RemoveMediaFilesUseCase(this._files);

  final MediaFilesDatasource _files;

  Future<void> call(List<String> paths) => _files.remove(paths);
}
