import 'package:injectable/injectable.dart';

import '../../data/datasource/audience_datasource.dart';
import '../entity/audience_summary_entity.dart';

/// The follower, close-friends and hidden counts for any "who can see this" sheet (a story's, a post's).
@injectable
class GetAudienceSummaryUseCase {
  GetAudienceSummaryUseCase(this._audience);

  final AudienceDatasource _audience;

  Future<AudienceSummaryEntity> call() async {
    final summary = await _audience.getSummary();
    return AudienceSummaryEntity(
      followers: summary.followers ?? 0,
      closeFriends: summary.closeFriends ?? 0,
      hidden: summary.hidden ?? 0,
    );
  }
}
