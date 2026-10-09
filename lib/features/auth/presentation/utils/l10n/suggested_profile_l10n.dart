import 'package:flutter/widgets.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../profile/data/enums/suggestion_reason.dart';
import '../../../../profile/data/model/suggested_profile_model.dart';

extension SuggestedProfileL10n on SuggestedProfileModel {
  /// "{n} mutual friends" or "Lives in {city}"; null when neither is known (the line is then hidden).
  String? metaLine(BuildContext context) {
    final l10n = context.l10n;
    final mutual = mutualCount;
    if (reason == SuggestionReason.mutual && mutual != null && mutual > 0) {
      return l10n.mutualFriends(mutual);
    }
    final place = city;
    if (reason == SuggestionReason.city && place != null && place.isNotEmpty) {
      return l10n.livesIn(place);
    }
    return null;
  }
}
