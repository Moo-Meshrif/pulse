import 'package:injectable/injectable.dart';

import '../../data/enums/content_kind.dart';
import '../../data/repository/content_publish_repository.dart';

/// Drops the failed post, short or story; [id] names which one when several are in the line.
@injectable
class DiscardPublishUseCase {
  DiscardPublishUseCase(this._publish);

  final ContentPublishRepository _publish;

  void call(ContentKind kind, {String? id}) => _publish.discard(kind, id: id);
}
