import 'package:flutter/widgets.dart';

import '../extensions/l10n.dart';

/// Why someone reports a post or a story. [wire] is the `reports.reason` value the backend accepts.
enum ReportReason {
  spam('spam'),
  nudity('nudity'),
  hate('hate'),
  bullying('bullying'),
  violence('violence'),
  falseInfo('false_info'),
  other('other');

  const ReportReason(this.wire);

  final String wire;

  /// "Something else" asks for a note before it is sent; every other reason is sent at once.
  bool get needsNote => this == other;

  String l10n(BuildContext context) => switch (this) {
    ReportReason.spam => context.l10n.reportReasonSpam,
    ReportReason.nudity => context.l10n.reportReasonNudity,
    ReportReason.hate => context.l10n.reportReasonHate,
    ReportReason.bullying => context.l10n.reportReasonBullying,
    ReportReason.violence => context.l10n.reportReasonViolence,
    ReportReason.falseInfo => context.l10n.reportReasonFalseInfo,
    ReportReason.other => context.l10n.reportReasonOther,
  };
}
