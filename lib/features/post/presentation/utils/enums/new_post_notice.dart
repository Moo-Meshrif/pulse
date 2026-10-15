import 'package:flutter/widgets.dart';

import '../../../../../core/extensions/l10n.dart';
import '../new_post_limits.dart';

/// A one-shot message from the New post and Edit post screens' Cubits.
enum NewPostNotice {
  videoTooLong,
  videoTooBig,
  mediaLimit,
  shareFailed,
  saveFailed;

  String message(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      videoTooLong => l10n.newPostVideoTooLong(NewPostLimits.maxVideoMinutes),
      videoTooBig => l10n.newPostVideoTooBig(NewPostLimits.maxVideoMegabytes),
      mediaLimit => l10n.newPostMediaLimit(NewPostLimits.maxMedia),
      shareFailed => l10n.newPostShareFailed,
      saveFailed => l10n.editPostSaveFailed,
    };
  }
}
