import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/dimens/app_dimens.dart';
import '../app_text.dart';
import 'loading_overlay.dart';

// The pieces `LoadingOverlay` is made of, kept apart so its own file reads top to bottom. Internal to this
// folder: only `loading_overlay.dart` is exported.

/// The colours of one tone, worked out once.
class OverlayLook {
  const OverlayLook({
    required this.line,
    required this.text,
    required this.subtext,
    required this.track,
    required this.scrim,
  });

  factory OverlayLook.of(BuildContext context, LoadingTone tone) {
    final colors = context.appColors;
    return switch (tone) {
      LoadingTone.light => OverlayLook(
        line: colors.primary,
        text: colors.textPrimary,
        subtext: colors.textSecondary,
        track: colors.border,
        scrim: colors.background.withValues(alpha: 0.72),
      ),
      LoadingTone.dark => OverlayLook(
        line: colors.surface,
        text: colors.surface,
        subtext: colors.surface.withValues(alpha: 0.72),
        track: colors.surface.withValues(alpha: 0.22),
        scrim: colors.textPrimary.withValues(alpha: 0.55),
      ),
    };
  }

  final Color line;
  final Color text;
  final Color subtext;
  final Color track;
  final Color scrim;
}

/// The scrim over a blurred copy of what is behind it. [amount] (0..1) is how far it has come in: it scales
/// the blur and the scrim together. Fading a `BackdropFilter` with an opacity would blur nothing (it would
/// sample an empty layer), so the strength is animated instead, as the dialogs do.
class OverlayFrost extends StatelessWidget {
  const OverlayFrost({super.key, required this.color, this.amount = 1});

  final Color color;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final scrim = ColoredBox(color: color.withValues(alpha: color.a * amount));
    if (amount <= 0) return scrim;
    return BackdropFilter(
      // The design also saturates the backdrop 1.4x; `ImageFilter` has no colour filter in this Flutter
      // version, so only the blur is applied.
      filter: ui.ImageFilter.blur(
        sigmaX: OverlayDimens.blur * amount,
        sigmaY: OverlayDimens.blur * amount,
      ),
      child: scrim,
    );
  }
}

/// The line, then the label, then the progress, each only when given.
class OverlayContent extends StatelessWidget {
  const OverlayContent({
    super.key,
    required this.look,
    this.label,
    this.progress,
  });

  final OverlayLook look;
  final String? label;
  final ValueListenable<double>? progress;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    final progress = this.progress;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseLineLoader(color: look.line),
        if (label != null) ...[
          SizedBox(height: OverlayDimens.labelGap),
          AppText(
            label,
            style: context.text.overlayLabel,
            color: look.text,
            textAlign: TextAlign.center,
          ),
        ],
        if (progress != null)
          Padding(
            padding: EdgeInsets.only(top: OverlayDimens.progressGap),
            child: OverlayProgress(look: look, progress: progress),
          ),
      ],
    );
  }
}

/// A thin bar and the percentage beside it.
class OverlayProgress extends StatelessWidget {
  const OverlayProgress({
    super.key,
    required this.look,
    required this.progress,
  });

  final OverlayLook look;
  final ValueListenable<double> progress;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
    valueListenable: progress,
    builder: (context, value, _) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: OverlayDimens.progressTrackWidth,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              OverlayDimens.progressTrackRadius,
            ),
            child: LinearProgressIndicator(
              value: value,
              minHeight: OverlayDimens.progressTrackHeight,
              color: look.line,
              backgroundColor: look.track,
            ),
          ),
        ),
        SizedBox(width: OverlayDimens.percentGap),
        SizedBox(
          width: OverlayDimens.percentWidth,
          child: AppText(
            '${(value * 100).round()}%',
            style: context.text.overlayPercent,
            color: look.subtext,
          ),
        ),
      ],
    ),
  );
}
