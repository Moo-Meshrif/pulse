import 'package:flutter/widgets.dart';

import '../../../../../core/extensions/l10n.dart';

/// A short notice the "link sent" dialog shows as a snackbar.
enum ResetLinkMessage {
  /// The link was sent again.
  resent,

  /// Sending it again failed.
  resendFailed,

  /// No mail app could be opened.
  noEmailApp;

  String l10n(BuildContext context) => switch (this) {
    resent => context.l10n.linkResent,
    resendFailed => context.l10n.errorGeneric,
    noEmailApp => context.l10n.noEmailApp,
  };
}
