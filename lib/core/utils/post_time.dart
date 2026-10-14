import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// How long ago a post was made: `now`, `5m`, `2h`, `1d`, `3w`, then the date (`12 Mar`, localized). A time
/// in the future (clock drift) counts as now.
String postTime(AppLocalizations l10n, DateTime postedAt, DateTime now) {
  final elapsed = now.difference(postedAt);
  if (elapsed.inMinutes < 1) return l10n.postTimeNow;
  if (elapsed.inHours < 1) return l10n.postTimeMinutes(elapsed.inMinutes);
  if (elapsed.inDays < 1) return l10n.postTimeHours(elapsed.inHours);
  if (elapsed.inDays < 7) return l10n.postTimeDays(elapsed.inDays);
  if (elapsed.inDays < 28) return l10n.postTimeWeeks(elapsed.inDays ~/ 7);
  return DateFormat('d MMM', l10n.localeName).format(postedAt);
}
