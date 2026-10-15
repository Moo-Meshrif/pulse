import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../notice/notice.dart';
import '../../notice/notices.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/dimens/app_dimens.dart';
import '../app_svg_icon.dart';
import '../app_text.dart';

/// The dark floating card of a [Notice]: icon, text, optional action pill and a bar that shrinks over the
/// notice's duration. It dismisses itself when the bar runs out, on a tap, on a swipe up, or after its
/// action; a long press holds the timer.
class NoticeCard extends StatefulWidget {
  const NoticeCard({
    super.key,
    required this.notice,
    required this.onDismiss,
    required this.onAction,
  });

  final Notice notice;
  final VoidCallback onDismiss;
  final VoidCallback onAction;

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timer =
      AnimationController(vsync: this, duration: widget.notice.duration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onDismiss();
        });
  double _dragUp = 0;

  @override
  void initState() {
    super.initState();
    if (Notices.autoDismiss) _timer.forward();
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragUp -= details.delta.dy;
    if (_dragUp >= NoticeDimens.swipeDismiss) {
      _dragUp = 0;
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;
    final radius = BorderRadius.circular(AppRadius.card);
    return Semantics(
      container: true,
      liveRegion: true,
      child: GestureDetector(
        onTap: widget.onDismiss,
        onVerticalDragUpdate: _onDragUpdate,
        onLongPressStart: (_) => _timer.stop(),
        onLongPressEnd: (_) => _timer.forward(),
        onLongPressCancel: () => _timer.forward(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: AppShadows.notice,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: NoticeDimens.blurSigma,
                sigmaY: NoticeDimens.blurSigma,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: NoticeColors.surface,
                  borderRadius: radius,
                  border: Border.all(
                    color: NoticeColors.border,
                    width: NoticeDimens.borderWidth,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: NoticeDimens.padding,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              NoticeDimens.minHeight -
                              NoticeDimens.padding.vertical,
                        ),
                        child: Row(
                          children: [
                            _NoticeIcon(kind: notice.kind, icon: notice.icon),
                            SizedBox(width: NoticeDimens.gap),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    notice.title,
                                    style: context.text.noticeTitle,
                                    color: NoticeColors.title,
                                    maxLines: 3,
                                  ),
                                  if (notice.message != null)
                                    AppText(
                                      notice.message!,
                                      style: context.text.caption,
                                      color: NoticeColors.message,
                                      maxLines: 3,
                                    ),
                                ],
                              ),
                            ),
                            if (notice.hasAction) ...[
                              SizedBox(width: NoticeDimens.gap),
                              _NoticeAction(
                                label: notice.actionLabel!,
                                onTap: widget.onAction,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      bottom: NoticeDimens.timerBottom,
                      start:
                          NoticeDimens.padding.start +
                          NoticeDimens.iconCircle +
                          NoticeDimens.gap,
                      end: NoticeDimens.padding.end,
                      height: NoticeDimens.timerHeight,
                      child: AnimatedBuilder(
                        animation: _timer,
                        builder: (context, _) => FractionallySizedBox(
                          widthFactor: 1 - _timer.value,
                          alignment: AlignmentDirectional.centerStart,
                          child: const ColoredBox(color: NoticeColors.timer),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeIcon extends StatelessWidget {
  const _NoticeIcon({required this.kind, this.icon});

  final NoticeKind kind;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final (asset, color) = switch (kind) {
      NoticeKind.error => (AppAssets.noticeError, NoticeColors.error),
      NoticeKind.success => (AppAssets.noticeSuccess, NoticeColors.success),
      NoticeKind.info => (AppAssets.noticeInfo, NoticeColors.info),
    };
    return ExcludeSemantics(
      child: Container(
        width: NoticeDimens.iconCircle,
        height: NoticeDimens.iconCircle,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(0x26),
        ),
        child: AppSvgIcon(icon ?? asset, size: NoticeDimens.icon, color: color),
      ),
    );
  }
}

class _NoticeAction extends StatelessWidget {
  const _NoticeAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.tapTarget),
        child: Center(
          child: Container(
            height: NoticeDimens.actionHeight,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: NoticeDimens.actionSide),
            decoration: BoxDecoration(
              color: NoticeColors.actionFill,
              borderRadius: BorderRadius.circular(
                AppRadius.pill(NoticeDimens.actionHeight),
              ),
            ),
            child: AppText(
              label,
              style: context.text.noticeAction,
              color: NoticeColors.actionText,
              maxLines: 1,
            ),
          ),
        ),
      ),
    ),
  );
}
