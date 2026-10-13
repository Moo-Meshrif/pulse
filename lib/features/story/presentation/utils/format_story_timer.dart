/// `0:21` for the recording timer.
String formatStoryTimer(Duration elapsed) {
  final seconds = elapsed.inSeconds;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}
