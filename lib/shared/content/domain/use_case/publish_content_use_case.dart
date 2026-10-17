import 'package:injectable/injectable.dart';

import '../../data/enums/content_kind.dart';
import '../../data/repository/content_publish_repository.dart';

/// Hands content to the background sender. Returns false while another one of [kind] is going out (or
/// has failed and waits for Retry or Discard).
@injectable
class PublishContentUseCase {
  PublishContentUseCase(this._publish);

  final ContentPublishRepository _publish;

  bool call({
    required ContentKind kind,
    required PublishWork send,
    bool isEdit = false,
    String? previewPath,
    String? previewUrl,
    String? previewCacheKey,
  }) => _publish.enqueue(
    kind: kind,
    send: send,
    isEdit: isEdit,
    previewPath: previewPath,
    previewUrl: previewUrl,
    previewCacheKey: previewCacheKey,
  );
}
