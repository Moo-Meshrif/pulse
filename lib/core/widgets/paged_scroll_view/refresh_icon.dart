import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../../theme/dimens/app_dimens.dart';
import '../app_svg_icon.dart';

/// The refresh indicator of a main screen: that screen's nav icon. While the finger pulls, [progress]
/// (0 to 1) grows and fades it in and fills the outline; while [isRefreshing] it pulses until done.
class RefreshIcon extends StatefulWidget {
  const RefreshIcon({
    super.key,
    required this.icon,
    required this.filledIcon,
    required this.progress,
    required this.isRefreshing,
  });

  final String icon;
  final String filledIcon;
  final double progress;
  final bool isRefreshing;

  @override
  State<RefreshIcon> createState() => _RefreshIconState();
}

class _RefreshIconState extends State<RefreshIcon>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  // Not initState: it reads MediaQuery, which is only allowed from here on.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(RefreshIcon old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final shouldPulse =
        widget.isRefreshing && !MediaQuery.disableAnimationsOf(context);
    if (shouldPulse && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldPulse && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.primary;
    final size = LoadingDimens.refreshIconSize;
    final progress = widget.progress.clamp(0.0, 1.0);
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pulse = widget.isRefreshing
              ? 1 + 0.2 * math.sin(_controller.value * 2 * math.pi)
              : 1.0;
          final scale = widget.isRefreshing ? pulse : 0.6 + 0.4 * progress;
          final fill = widget.isRefreshing ? 1.0 : progress;
          return Opacity(
            opacity: widget.isRefreshing ? 1 : progress,
            child: Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AppSvgIcon(widget.icon, size: size, color: color),
                  Opacity(
                    opacity: fill,
                    child: AppSvgIcon(
                      widget.filledIcon,
                      size: size,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
