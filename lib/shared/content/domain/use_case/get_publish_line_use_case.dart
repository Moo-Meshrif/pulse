import 'package:injectable/injectable.dart';

import '../../data/enums/content_kind.dart';
import '../../data/repository/content_publish_repository.dart';
import '../entity/content_publish_line.dart';

/// Everything of [kind] in the line of what is being sent now; later changes come on the `EventBus` as
/// `ContentPublishLine`.
@injectable
class GetPublishLineUseCase {
  GetPublishLineUseCase(this._publish);

  final ContentPublishRepository _publish;

  ContentPublishLine call(ContentKind kind) => _publish.line(kind);
}
