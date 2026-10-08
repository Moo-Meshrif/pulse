/// A wait as `m:ss` ("0:30", "14:59"); it never shows less than a second. Used by the sign-in
/// throttle message and the resend-code cooldown.
String formatCountdown(Duration remaining) {
  final seconds = remaining.inMilliseconds <= 0
      ? 0
      : (remaining.inMilliseconds / 1000).ceil();
  final minutes = seconds ~/ 60;
  return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
}
