import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../dimens/story_constants.dart';
import '../../dimens/story_dimens.dart';

/// The shutter: tap = photo, hold = video. While recording the ring grows to 92, fills with `like` over
/// 60 seconds and the dot becomes a red rounded square.
class StoryShutter extends StatelessWidget {
  const StoryShutter({
    super.key,
    required this.isRecording,
    required this.progress,
    required this.onTap,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  final bool isRecording;

  /// 0..1 of the 60 second limit.
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final duration = reduce ? Duration.zero : StoryMotion.likePop;
    // The 92 ring is the largest: the slot stays that size so the row does not jump.
    return Semantics(
      button: true,
      label: context.l10n.storyShutter,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPressStart: (_) => onHoldStart(),
        onLongPressEnd: (_) => onHoldEnd(),
        onLongPressCancel: onHoldEnd,
        child: SizedBox.square(
          dimension: StoryCameraDimens.recordRing,
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              width: isRecording
                  ? StoryCameraDimens.recordRing
                  : StoryCameraDimens.shutter,
              height: isRecording
                  ? StoryCameraDimens.recordRing
                  : StoryCameraDimens.shutter,
              child: CustomPaint(
                painter: _RingPainter(
                  trackColor: isRecording
                      ? colors.onDark.withValues(
                          alpha: StoryOpacity.recordTrack,
                        )
                      : colors.onDark,
                  progressColor: colors.like,
                  progress: isRecording ? progress : 0,
                  width: StoryCameraDimens.shutterRing,
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: duration,
                    width: isRecording
                        ? StoryCameraDimens.recordStop
                        : StoryCameraDimens.shutterDot,
                    height: isRecording
                        ? StoryCameraDimens.recordStop
                        : StoryCameraDimens.shutterDot,
                    decoration: BoxDecoration(
                      color: isRecording ? colors.like : colors.onDark,
                      borderRadius: BorderRadius.circular(
                        isRecording
                            ? StoryCameraDimens.recordStopRadius
                            : StoryCameraDimens.shutterDot,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.trackColor,
    required this.progressColor,
    required this.progress,
    required this.width,
  });

  final Color trackColor;
  final Color progressColor;
  final double progress;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = trackColor,
    );
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..color = progressColor,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.trackColor != trackColor ||
      old.progress != progress ||
      old.width != width;
}
