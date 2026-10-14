import 'package:flutter/foundation.dart';

import '../../../../core/theme/app_dimens.dart';

/// Decides which video of a list plays: the one that is at least [PostCardDimens.playVisibleFraction]
/// visible, the most visible when several are, and the same one for as long as it stays visible enough.
/// Videos start muted; the mute button is one switch for the whole list.
class PostVideoCoordinator extends ChangeNotifier {
  final _fractions = <String, double>{};
  String? _activeId;
  bool _isMuted = true;

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
    notifyListeners();
  }
}
