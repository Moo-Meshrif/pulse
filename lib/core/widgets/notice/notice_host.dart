import 'package:flutter/material.dart';

import '../../notice/notice.dart';
import '../../notice/notices.dart';
import '../../theme/dimens/app_dimens.dart';
import 'notice_card.dart';

/// Puts the notice card above every route, sheet and dialog (it wraps the Navigator in `App`'s builder).
/// Shows what `Notices.current` holds: the card drops in from the top, and leaves upward before the next
/// one comes.
class NoticeHost extends StatefulWidget {
  const NoticeHost({super.key, required this.child});

  final Widget child;

  @override
  State<NoticeHost> createState() => _NoticeHostState();
}

class _NoticeHostState extends State<NoticeHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: NoticeDimens.enter,
    reverseDuration: NoticeDimens.exit,
  );
  Notice? _shown;
  int _run = 0;

  @override
  void initState() {
    super.initState();
    Notices.current.addListener(_sync);
    _sync();
  }

  @override
  void dispose() {
    Notices.current.removeListener(_sync);
    _motion.dispose();
    Notices.clear();
    super.dispose();
  }

  Future<void> _sync() async {
    final target = Notices.current.value;
    if (target == _shown) return;
    final run = ++_run;
    if (_shown != null) {
      await _motion.reverse();
      if (!mounted || run != _run) return;
    }
    setState(() => _shown = target);
    if (target != null) _motion.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        if (shown != null)
          PositionedDirectional(
            top: MediaQuery.paddingOf(context).top + NoticeDimens.topGap,
            start: NoticeDimens.side,
            end: NoticeDimens.side,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: NoticeDimens.maxWidth),
                child: _Entrance(
                  motion: _motion,
                  child: Material(
                    type: MaterialType.transparency,
                    child: NoticeCard(
                      key: ValueKey(shown),
                      notice: shown,
                      onDismiss: () => Notices.dismiss(shown),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Slide down + fade + scale in with a spring-like overshoot; the reverse runs the other way (up and
/// fade). With reduced motion it only fades.
class _Entrance extends StatelessWidget {
  const _Entrance({required this.motion, required this.child});

  final Animation<double> motion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: motion, curve: Curves.easeOut);
    final spring = CurvedAnimation(
      parent: motion,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    final still = MediaQuery.disableAnimationsOf(context);
    return FadeTransition(
      opacity: fade,
      child: still
          ? child
          : AnimatedBuilder(
              animation: spring,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  0,
                  -(1 - spring.value) * NoticeDimens.enterOffset,
                ),
                child: Transform.scale(
                  scale:
                      NoticeDimens.enterScale +
                      (1 - NoticeDimens.enterScale) * spring.value,
                  child: child,
                ),
              ),
              child: child,
            ),
    );
  }
}
