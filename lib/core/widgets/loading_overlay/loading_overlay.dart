import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../extensions/l10n.dart';
import '../../theme/dimens/app_dimens.dart';
import 'overlay_parts.dart';

// The folder's public surface: the overlay and how to show it, plus the heartbeat line it draws.
export 'pulse_line_loader.dart';

/// Light everywhere; dark over photos and video.
enum LoadingTone { light, dark }

/// Frosts the screen with a [LoadingOverlay] while [task] runs. It fades in at once and, the moment the
/// task ends, fades out again (the result is returned straight away, so the next screen is already there
/// as the overlay lifts). Taps are blocked until it is gone. An error from the task passes through.
///
/// Not for first-load screens (they use skeletons) or buttons (they spin themselves).
Future<T> runWithLoadingOverlay<T>(
  BuildContext context,
  Future<T> Function() task, {
  String? label,
  ValueListenable<double>? progress,
  LoadingTone tone = LoadingTone.light,
}) async {
  final visible = ValueNotifier(true);
  final overlay = OverlayEntry(
    builder: (_) => LoadingOverlay(
      label: label,
      progress: progress,
      tone: tone,
      visible: visible,
    ),
  );
  Overlay.of(context, rootOverlay: true).insert(overlay);
  try {
    return await task();
  } finally {
    unawaited(_lift(overlay, visible));
  }
}

/// Fades the overlay out, then takes it off the screen.
Future<void> _lift(OverlayEntry overlay, ValueNotifier<bool> visible) async {
  visible.value = false;
  await Future<void>.delayed(OverlayDimens.exit);
  overlay.remove();
  overlay.dispose();
  // `visible` is not disposed: the overlay's state still removes its listener when it goes, and the
  // notifier holds nothing else to release.
}

/// No card: the screen frosts over and the heartbeat line traces across the middle, with an optional
/// [label] and [progress] (0..1) under it. It fades and rises in on show, and fades out when [visible]
/// turns false. Usually shown by `runWithLoadingOverlay`.
class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    super.key,
    this.label,
    this.progress,
    this.tone = LoadingTone.light,
    this.visible,
  });

  final String? label;
  final ValueListenable<double>? progress;
  final LoadingTone tone;

  /// Turns false to start the exit; null keeps the overlay up.
  final ValueListenable<bool>? visible;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: OverlayDimens.enter,
    reverseDuration: OverlayDimens.exit,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  @override
  void initState() {
    super.initState();
    widget.visible?.addListener(_followVisible);
    _controller.forward();
  }

  void _followVisible() {
    if (widget.visible!.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    widget.visible?.removeListener(_followVisible);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final look = OverlayLook.of(context, widget.tone);
    return PopScope(
      canPop: false,
      child: Semantics(
        liveRegion: true,
        label: widget.label ?? context.l10n.loading,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) => Stack(
            fit: StackFit.expand,
            children: [
              const ModalBarrier(dismissible: false),
              // The frost is not inside the fade: see `OverlayFrost`.
              OverlayFrost(color: look.scrim, amount: _progress.value),
              Center(
                child: Opacity(
                  opacity: _progress.value,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      OverlayDimens.rise * (1 - _progress.value),
                    ),
                    child: OverlayContent(
                      look: look,
                      label: widget.label,
                      progress: widget.progress,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
