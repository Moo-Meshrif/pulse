import 'package:injectable/injectable.dart';

import '../../data/datasource/privacy_datasource.dart';
import '../../data/enums/content_audience.dart';

/// Saves the audience new posts start with ("Use for future posts").
@injectable
class SaveDefaultAudienceUseCase {
  SaveDefaultAudienceUseCase(this._privacy);

  final PrivacyDatasource _privacy;

  Future<void> call(ContentAudience visibility) =>
      _privacy.setDefaultAudience(visibility);
}
