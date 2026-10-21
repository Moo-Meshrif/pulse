import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/colors/app_colors.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../cubit/story_edit/story_edit_cubit.dart';
import '../../dimens/story_constants.dart';
import '../../dimens/story_dimens.dart';
import '../../utils/format_story_timer.dart';

/// Under a video longer than a story can be: frames along the whole video, dimmed outside the part that is
/// shared, which sits in a framed window with a grip at each end (like WhatsApp). Drag a grip to move that
/// end, or the window to slide it; the Cubit keeps it within the story's longest length. Time runs left to
/// right in both languages.
class StoryTrimBar extends StatefulWidget {
  const StoryTrimBar({
    super.key,
    required this.durationMs,
    required this.startMs,
    required this.endMs,
    required this.frames,
    required this.onStart,
    required this.onEnd,
    required this.onMove,
  });

  final int durationMs;
  final int startMs;
  final int endMs;

  /// Evenly spaced frames of the video; empty tiles show until they are read.
  final List<Uint8List> frames;
  final ValueChanged<int> onStart;
  final ValueChanged<int> onEnd;

  /// Slides the whole window; told where it should start.
  final ValueChanged<int> onMove;

  @override
  State<StoryTrimBar> createState() => _StoryTrimBarState();
}

class _StoryTrimBarState extends State<StoryTrimBar> {
  /// What the finger is moving, while it moves (not on a plain press): the time of that point shows above
  /// the bar.
  final _touch = ValueNotifier<_Touch?>(null);

  int get durationMs => widget.durationMs;
  int get startMs => widget.startMs;
  int get endMs => widget.endMs;

  @override
  void dispose() {
    _touch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: StoryTrimDimens.gap,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: LayoutBuilder(
            builder: (context, box) {
              final width = box.maxWidth;
              final left = width * startMs / durationMs;
              final right = width * endMs / durationMs;
              int msOf(double dx) => (dx / width * durationMs).round();
              return SizedBox(
                height: StoryTrimDimens.barHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          StoryTrimDimens.radius,
                        ),
                        child: _Frames(frames: widget.frames),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      width: left,
                      top: 0,
                      bottom: 0,
                      child: _Dim(color: colors.black),
                    ),
                    Positioned(
                      left: right,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: _Dim(color: colors.black),
                    ),
                    Positioned(
                      left: left,
                      width: right - left,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragStart: (_) => _touch.value = _Touch.move,
                        onHorizontalDragEnd: (_) => _touch.value = null,
                        onHorizontalDragCancel: () => _touch.value = null,
                        onHorizontalDragUpdate: (details) =>
                            widget.onMove(startMs + msOf(details.delta.dx)),
                        child: _Window(color: colors.onDark),
                      ),
                    ),
                    _Grip(
                      left: left - StoryTrimDimens.gripHit / 2,
                      onTouch: (touch) =>
                          _touch.value = touch ? _Touch.start : null,
                      onDrag: (dx) => widget.onStart(startMs + msOf(dx)),
                    ),
                    _Grip(
                      left: right - StoryTrimDimens.gripHit / 2,
                      onTouch: (touch) =>
                          _touch.value = touch ? _Touch.end : null,
                      onDrag: (dx) => widget.onEnd(endMs + msOf(dx)),
                    ),
                    ValueListenableBuilder<_Touch?>(
                      valueListenable: _touch,
                      builder: (context, touch, _) => touch == null
                          ? const SizedBox.shrink()
                          : _TimeBubble(
                              x: touch == _Touch.end ? right : left,
                              ms: touch == _Touch.end ? endMs : startMs,
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Center(
          child: AppText(
            context.l10n.storyTrimHint,
            style: context.text.chipLabel,
            color: colors.onDark,
          ),
        ),
      ],
    );
  }
}

class _Frames extends StatelessWidget {
  const _Frames({required this.frames});

  final List<Uint8List> frames;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < StoryEditCubit.trimFrameCount; i++)
        Expanded(
          child: i < frames.length
              ? Image.memory(
                  frames[i],
                  fit: BoxFit.cover,
                  height: double.infinity,
                  gaplessPlayback: true,
                )
              : const ColoredBox(color: StoryColors.control),
        ),
    ],
  );
}

class _Dim extends StatelessWidget {
  const _Dim({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: color.withValues(alpha: StoryOpacity.trimDim));
}

/// The kept part: a frame with a grip at each end.
class _Window extends StatelessWidget {
  const _Window({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(width: StoryTrimDimens.border, color: color),
        vertical: BorderSide(width: StoryTrimDimens.grip, color: color),
      ),
      borderRadius: BorderRadius.circular(StoryTrimDimens.radius),
    ),
  );
}

/// A wide touch area over an end of the window, so a thumb can take it.
class _Grip extends StatelessWidget {
  const _Grip({
    required this.left,
    required this.onDrag,
    required this.onTouch,
  });

  final double left;
  final ValueChanged<double> onDrag;

  /// True when a finger lands on the grip, false when it lets go.
  final ValueChanged<bool> onTouch;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    width: StoryTrimDimens.gripHit,
    top: 0,
    bottom: 0,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => onTouch(true),
      onHorizontalDragEnd: (_) => onTouch(false),
      onHorizontalDragCancel: () => onTouch(false),
      onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
    ),
  );
}

enum _Touch { start, end, move }

/// The time at a point of the bar in a grey pill with a line down to it: `02:15.09`.
class _TimeBubble extends StatelessWidget {
  const _TimeBubble({required this.x, required this.ms});

  final double x;
  final int ms;

  String get _label {
    final centis = ms ~/ 10 % 100;
    return '${formatStoryTimer(Duration(milliseconds: ms)).padLeft(5, '0')}'
        '.${centis.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Positioned(
      left: x,
      bottom: StoryTrimDimens.barHeight,
      child: IgnorePointer(
        child: FractionalTranslation(
          translation: const Offset(-0.5, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: StoryColors.bubble,
                  borderRadius: BorderRadius.circular(StoryTrimDimens.radius),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: StoryTrimDimens.bubblePadding,
                    vertical: StoryTrimDimens.bubblePaddingV,
                  ),
                  child: AppText(
                    _label,
                    style: context.text.chipLabel,
                    color: colors.onDark,
                  ),
                ),
              ),
              Container(
                width: StoryTrimDimens.lineWidth,
                height: StoryTrimDimens.lineHeight,
                color: colors.onDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
