import 'package:injectable/injectable.dart';

import '../../data/datasource/privacy_datasource.dart';
import '../../data/enums/content_audience.dart';
import '../entity/privacy_entity.dart';

/// `profile`'s public answer for the New post audience: is the account private, and which audience a
/// new post starts with. A private account never starts Public.
@injectable
class GetPrivacyUseCase {
  GetPrivacyUseCase(this._privacy);

  final PrivacyDatasource _privacy;

  Future<PrivacyEntity> call() async {
    final privacy = await _privacy.getPrivacy();
    final isPrivate = privacy.isPrivate ?? false;
    var visibility = privacy.defaultAudience ?? ContentAudience.public;
    if (isPrivate && visibility == ContentAudience.public) {
      visibility = ContentAudience.followers;
    }
    return PrivacyEntity(isPrivate: isPrivate, defaultVisibility: visibility);
  }
}
