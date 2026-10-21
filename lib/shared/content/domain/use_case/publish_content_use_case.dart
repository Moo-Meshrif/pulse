import 'package:injectable/injectable.dart';

import '../../data/enums/content_kind.dart';
import '../../data/repository/content_publish_repository.dart';

/// Hands content to the background sender. Returns false while another one of [kind] is going out (or
/// has failed and waits for Retry or Discard). [pendingId] is the id the server knows it by before it is
/// posted, so discarding a failed one discards it there too; [onDiscard] runs when a failed one is
/// discarded, for the device side.
@injectable
class PublishContentUseCase {
  PublishContentUseCase(this._publish);

  final ContentPublishRepository _publish;

  bool call({
    required ContentKind kind,
    required PublishWork send,
    String? pendingId,
    Future<void> Function()? onDiscard,
    bool isEdit = false,
    String? previewPath,
    String? previewUrl,
    String? previewCacheKey,
  }) => _publish.enqueue(
    kind: kind,
    send: send,
    pendingId: pendingId,
    onDiscard: onDiscard,
    isEdit: isEdit,
    previewPath: previewPath,
    previewUrl: previewUrl,
    previewCacheKey: previewCacheKey,
  );
}
