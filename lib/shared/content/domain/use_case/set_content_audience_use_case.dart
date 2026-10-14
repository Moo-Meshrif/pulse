import 'package:injectable/injectable.dart';

import '../../data/datasource/content_actions_datasource.dart';
import '../../data/enums/content_audience.dart';
import '../../data/enums/content_kind.dart';

/// Changes who can see the signed-in user's post, short or story.
@injectable
class SetContentAudienceUseCase {
  SetContentAudienceUseCase(this._actions);

  final ContentActionsDatasource _actions;

  Future<void> call(ContentKind kind, String id, ContentAudience audience) =>
      _actions.setAudience(kind, id, audience);
}
