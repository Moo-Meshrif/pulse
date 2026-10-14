import 'package:injectable/injectable.dart';

import '../../../../core/enums/report_reason.dart';
import '../../data/datasource/content_actions_datasource.dart';
import '../../data/enums/content_kind.dart';

/// Reports a post, a short or a story. For a post or a short the server also hides it for the reporter.
@injectable
class ReportContentUseCase {
  ReportContentUseCase(this._actions);

  final ContentActionsDatasource _actions;

  Future<void> call(
    ContentKind kind,
    String id,
    ReportReason reason, {
    String? note,
  }) => _actions.report(kind, id, reason, note: note);
}
