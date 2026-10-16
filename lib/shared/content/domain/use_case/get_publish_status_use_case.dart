import 'package:injectable/injectable.dart';

import '../../data/enums/content_kind.dart';
import '../../data/repository/content_publish_repository.dart';
import '../entity/content_publish_status.dart';

/// How sending content of [kind] stands now; later changes come on the `EventBus` as
/// `ContentPublishStatus`.
@injectable
class GetPublishStatusUseCase {
  GetPublishStatusUseCase(this._publish);

  final ContentPublishRepository _publish;

  ContentPublishStatus call(ContentKind kind) => _publish.current(kind);
}
