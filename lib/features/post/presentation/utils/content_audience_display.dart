import 'package:flutter/widgets.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../shared/content/data/enums/content_audience.dart';

/// How a [ContentAudience] looks in the post screens.
extension ContentAudienceDisplay on ContentAudience {
  String get icon => switch (this) {
    ContentAudience.public => AppAssets.globe,
    ContentAudience.followers => AppAssets.audience,
    ContentAudience.closeFriends => AppAssets.star,
    ContentAudience.onlyMe => AppAssets.lock,
  };

  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      ContentAudience.public => l10n.postAudiencePublic,
      ContentAudience.followers => l10n.postAudienceFollowers,
      ContentAudience.closeFriends => l10n.postAudienceCloseFriends,
      ContentAudience.onlyMe => l10n.postAudienceOnlyMe,
    };
  }

  /// The one-time notice for the first post to this audience; null for the others.
  String? noticeTitle(BuildContext context) => switch (this) {
    ContentAudience.closeFriends =>
      context.l10n.postVisibilityNoticeCloseFriendsTitle,
    ContentAudience.onlyMe => context.l10n.postVisibilityNoticeOnlyMeTitle,
    ContentAudience.public || ContentAudience.followers => null,
  };

  String? noticeBody(BuildContext context, {required int reach}) =>
      switch (this) {
        ContentAudience.closeFriends =>
          context.l10n.postVisibilityNoticeCloseFriendsBody(reach),
        ContentAudience.onlyMe => context.l10n.postVisibilityNoticeOnlyMeBody,
        ContentAudience.public || ContentAudience.followers => null,
      };
}
