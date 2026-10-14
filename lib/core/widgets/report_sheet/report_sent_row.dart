import 'dart:ui' show VoidCallback;

/// An extra row on the thanks step ("Mute @x", "Unfollow @x"): the sheet closes, then [onTap] runs.
class ReportSentRow {
  const ReportSentRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;
}
