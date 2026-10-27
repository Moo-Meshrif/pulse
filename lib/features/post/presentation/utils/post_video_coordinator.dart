import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../dimens/post_card_dimens.dart';

/// Decides which video of a list plays: the one that is at least [PostCardDimens.playVisibleFraction]
/// visible, the most visible when several are, and the same one for as long as it stays visible enough.
/// Videos start muted; the mute button is one switch for the whole list.
class PostVideoCoordinator extends ChangeNotifier {
  /// [_isMuted] false starts with sound: the post page (the feed starts muted).
  PostVideoCoordinator({this._isMuted = true});

  final _fractions = <String, double>{};
  String? _activeId;
  bool _isMuted;

  /// The video that should play now, or null.
  String? get activeId => _activeId;
  bool get isMuted => _isMuted;

  void report(String id, double fraction) {
    if (fraction <= 0) {
      _fractions.remove(id);
    } else {
      _fractions[id] = fraction;
    }
    _choose();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void _choose() {
    const threshold = PostCardDimens.playVisibleFraction;
    final current = _fractions[_activeId];
    if (current != null && current >= threshold) return;
    String? best;
    var bestFraction = threshold;
    for (final entry in _fractions.entries) {
      if (entry.value >= bestFraction) {
        best = entry.key;
        bestFraction = entry.value;
      }
    }
    if (best == _activeId) return;
    _activeId = best;
    _notifySafely();
  }

  /// A video leaving the list reports while the framework unmounts it (the tree is locked), so listeners
  /// that rebuild are told after the frame.
  void _notifySafely() {
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      notifyListeners();
      return;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) notifyListeners();
    });
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
