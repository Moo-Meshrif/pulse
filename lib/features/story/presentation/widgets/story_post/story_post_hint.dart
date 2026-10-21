import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/story_post_sticker_style.dart';
import '../../dimens/story_constants.dart';
import '../../dimens/story_dimens.dart';
import '../../utils/story_post_background.dart';

/// Above the bottom actions: the three dots of the sticker's style, then the hint, or the background
/// swatches while the palette tool is open.
class StoryPostHint extends StatelessWidget {
  const StoryPostHint({
    super.key,
    required this.style,
    required this.isPaletteOpen,
    required this.backgrounds,
    required this.selected,
    required this.onChoose,
  });

  final StoryPostStickerStyle style;
  final bool isPaletteOpen;
  final List<StoryPostBackground> backgrounds;
  final int selected;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    spacing: StoryPostDimens.hintGap,
    children: [
      _Dots(style: style),
      if (isPaletteOpen)
        _Swatches(
          backgrounds: backgrounds,
          selected: selected,
          onChoose: onChoose,
        )
      else
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: AppText(
            context.l10n.storyPostStickerHint,
            style: context.text.bodyXs,
            color: context.appColors.onDark.withValues(
              alpha: StoryOpacity.hint,
            ),
            textAlign: TextAlign.center,
          ),
        ),
    ],
  );
}

class _Dots extends StatelessWidget {
  const _Dots({required this.style});

  final StoryPostStickerStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: StoryPostDimens.dotGap,
        children: [
          for (final item in StoryPostStickerStyle.values)
            AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : StoryMotion.uiFade,
              width: item == style
                  ? StoryPostDimens.dotActiveWidth
                  : StoryPostDimens.dotHeight,
              height: StoryPostDimens.dotHeight,
              decoration: BoxDecoration(
                color: item == style
                    ? colors.onDark
                    : colors.onDark.withValues(alpha: StoryOpacity.recordTrack),
                borderRadius: BorderRadius.circular(
                  StoryPostDimens.dotHeight / 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({
    required this.backgrounds,
    required this.selected,
    required this.onChoose,
  });

  final List<StoryPostBackground> backgrounds;
  final int selected;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: StoryPostDimens.swatchGap,
      children: [
        for (final (i, background) in backgrounds.indexed)
          Semantics(
            button: true,
            selected: i == selected,
            label: l10n.storyBackgroundOption(i + 1),
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => onChoose(i),
              child: Container(
                width: StoryPostDimens.swatch,
                height: StoryPostDimens.swatch,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i == selected ? colors.onDark : Colors.transparent,
                    width: StoryPostDimens.swatchRing,
                  ),
                ),
                padding: EdgeInsets.all(StoryPostDimens.swatchRing),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: background.colors,
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
