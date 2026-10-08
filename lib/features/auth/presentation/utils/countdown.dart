import 'dart:async';

/// A countdown in whole seconds, owned by a Cubit (composition, not a base class). The Cubit keeps what is
/// shown in its state; this only counts and reports.
class Countdown {
  static const _tick = Duration(seconds: 1);

  Timer? _timer;

  bool get isRunning => _timer?.isActive ?? false;

  /// Counts down from [from], calling [onTick] once a second with the time left. The last call has
  /// [Duration.zero], after which the countdown stops by itself. Starting again replaces a running one.
  void start(Duration from, void Function(Duration left) onTick) {
    cancel();
    var left = from;
    _timer = Timer.periodic(_tick, (timer) {
      left -= _tick;
      if (left <= Duration.zero) {
        left = Duration.zero;
        timer.cancel();
      }
      onTick(left);
    });
  }

  /// Stops it without a final call. Safe to call when nothing runs; Cubits call it from `close()`.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
