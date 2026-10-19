import 'dart:async';

/// Calls [onSeen] with a story's id once it has been on screen, playing, for [delay]. Moving to another
/// story restarts it; pausing or finishing cancels it.
class StorySeenTimer {
  StorySeenTimer(this._onSeen);

  static const delay = Duration(seconds: 1);

  final void Function(String storyId) _onSeen;
  Timer? _timer;
  String? _storyId;

  /// Starts the wait for [storyId], or cancels it when [shouldRun] is false or there is no story.
  void sync({required String? storyId, required bool shouldRun}) {
    if (!shouldRun || storyId == null) return cancel();
    if (_storyId == storyId) return;
    _timer?.cancel();
    _storyId = storyId;
    _timer = Timer(delay, () {
      _timer = null;
      _storyId = null;
      _onSeen(storyId);
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _storyId = null;
  }
}
