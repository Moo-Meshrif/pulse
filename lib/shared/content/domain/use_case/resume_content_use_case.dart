import 'package:injectable/injectable.dart';

import '../../data/repository/content_discard_repository.dart';
import '../../data/repository/content_publish_repository.dart';

/// Run when the app starts or comes back for [userId]: another user's posts, shorts and stories going out
/// are dropped from view, a send that failed for the connection goes again, and the discards saved on
/// this device are finished (with the files of discarded items deleted). Never throws.
@injectable
class ResumeContentUseCase {
  ResumeContentUseCase(this._publish, this._discards);

  final ContentPublishRepository _publish;
  final ContentDiscardRepository _discards;

  Future<void> call(String? userId) {
    _publish
      ..useAccount(userId)
      ..retryLost();
    _discards.useAccount(userId);
    return _discards.sendSaved();
  }
}
