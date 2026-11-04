import '../../l10n/app_localizations.dart';

/// How long ago [at] was in words: `just now`, `5 minutes ago`, `2 weeks ago`, `1 month ago`. A time in the
/// future (clock drift) counts as now.
String timeAgo(AppLocalizations l10n, DateTime at, DateTime now) {
  final elapsed = now.difference(at);
  if (elapsed.inMinutes < 1) return l10n.timeAgoNow;
  if (elapsed.inHours < 1) return l10n.timeAgoMinutes(elapsed.inMinutes);
  if (elapsed.inDays < 1) return l10n.timeAgoHours(elapsed.inHours);
  if (elapsed.inDays < 7) return l10n.timeAgoDays(elapsed.inDays);
  if (elapsed.inDays < 30) return l10n.timeAgoWeeks(elapsed.inDays ~/ 7);
  if (elapsed.inDays < 365) return l10n.timeAgoMonths(elapsed.inDays ~/ 30);
  return l10n.timeAgoYears(elapsed.inDays ~/ 365);
}
