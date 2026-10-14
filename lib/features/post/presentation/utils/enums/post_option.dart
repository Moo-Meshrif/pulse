import 'package:flutter/widgets.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/l10n.dart';
import '../post_options_data.dart';

/// What the person picked in the post options sheet; the flow that opened the sheet carries it out.
enum PostOption {
  save,
  copyLink,
  share,
  notInterested,
  unfollow,
  mute,
  report,
  editCaption,
  changeAudience,
  toggleComments,
  delete;

  bool get isDanger => this == report || this == delete;

  String icon(PostOptionsData data) => switch (this) {
    save => data.isSaved ? AppAssets.bookmarkFilled : AppAssets.bookmark,
    copyLink => AppAssets.link,
    share => AppAssets.share,
    notInterested => AppAssets.eyeOff,
    unfollow => AppAssets.userMinus,
    mute => AppAssets.volumeOff,
    report => AppAssets.flag,
    editCaption => AppAssets.edit,
    changeAudience => AppAssets.audience,
    toggleComments => AppAssets.comment,
    delete => AppAssets.trash,
  };

  String title(BuildContext context, PostOptionsData data) {
    final l10n = context.l10n;
    return switch (this) {
      save => data.isSaved ? l10n.postSaved : l10n.postSave,
      copyLink => l10n.postCopyLink,
      share => l10n.postShare,
      notInterested => l10n.postNotInterested,
      unfollow => l10n.postUnfollow(data.username),
      mute => l10n.postMute(data.username),
      report => l10n.postReportTitle,
      editCaption => l10n.postEditCaption,
      changeAudience => l10n.postChangeWhoCanSee,
      toggleComments =>
        data.commentsEnabled ? l10n.postCommentsOff : l10n.postCommentsOn,
      delete => l10n.postDelete,
    };
  }

  String? hint(BuildContext context) => switch (this) {
    notInterested => context.l10n.postNotInterestedHint,
    mute => context.l10n.postMuteHint,
    _ => null,
  };
}
