import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../enums/sheet_tone.dart';
import '../extensions/context_extensions.dart';
import '../extensions/l10n.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_safe_area.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';

/// The shared bottom sheet (docs/specs/control/01-design-tokens.md > Create sheet): the Create sheet
/// today, the post options sheet later. A white sheet with a grabber and an optional title row with a close
/// button, over the `scrim`. Tapping the scrim, dragging down, the close button and system back dismiss it;
/// on wide windows it stays at the shared max width, centered. [SheetTone.dark] is the surface the story
/// screens use over media.
abstract final class AppBottomSheet {
  /// Shows [child] in the sheet; resolves with the value the sheet is popped with, or null when dismissed.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    SheetTone tone = SheetTone.light,
  }) => showModalBottomSheet<T>(
    context: context,
    // Over the main shell's nav bar, not inside a tab.
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: switch (tone) {
      SheetTone.light => context.appColors.scrim,
      SheetTone.dark => context.appColors.storyBlack.withValues(
        alpha: StoryOpacity.sheetScrim,
      ),
    },
    constraints: const BoxConstraints(maxWidth: AppBreakpoints.maxContentWidth),
    // The story sheets have their own timing; the light sheet keeps the framework's.
    sheetAnimationStyle: tone == SheetTone.dark
        ? storySheetAnimation(context)
        : null,
    builder: (_) => AppBottomSheetShell(title: title, tone: tone, child: child),
  );

  /// The story sheets' motion (docs/specs/story/source-tokens.md §8): in 260 ms, out 200 ms, both
  /// `easeOutCubic`; none when the system asks to reduce motion.
  static AnimationStyle storySheetAnimation(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle.noAnimation
      : AnimationStyle(
          duration: StoryMotion.sheetIn,
          reverseDuration: StoryMotion.sheetOut,
          curve: StoryMotion.curve,
          reverseCurve: StoryMotion.curve,
        );
}

/// The sheet itself: surface with the top radius and shadow, grabber, optional title row, then [child].
class AppBottomSheetShell extends StatelessWidget {
  const AppBottomSheetShell({
    super.key,
    required this.child,
    this.title,
    this.tone = SheetTone.light,
  });

  final Widget child;

  /// Shown at the start of the title row, next to the close button. No title, no row.
  final String? title;
  final SheetTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dark = tone == SheetTone.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? colors.storySheet : colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheetTop),
        ),
        boxShadow: AppShadows.bottomSheet,
      ),
      child: AppSafeArea(
        top: false,
        bottomSpace: BottomSheetDimens.bottomPadding,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            BottomSheetDimens.sidePadding,
            BottomSheetDimens.topPadding,
            BottomSheetDimens.sidePadding,
            BottomSheetDimens.bottomPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: BottomSheetDimens.grabberWidth,
                  height: BottomSheetDimens.grabberHeight,
                  decoration: BoxDecoration(
                    color: dark
                        ? colors.storyOnDark.withValues(
                            alpha: StoryOpacity.grabber,
                          )
                        : colors.border,
                    borderRadius: BorderRadius.circular(
                      BottomSheetDimens.grabberRadius,
                    ),
                  ),
                ),
              ),
              SizedBox(height: BottomSheetDimens.grabberToTitleGap),
              if (title != null) ...[
                _TitleRow(title: title!),
                SizedBox(height: BottomSheetDimens.titleToContentGap),
              ],
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: AppText(
            title,
            style: context.text.titleSm,
            color: colors.textPrimary,
            maxLines: 1,
          ),
        ),
        Semantics(
          button: true,
          label: context.l10n.close,
          excludeSemantics: true,
          child: InkResponse(
            onTap: () => Navigator.of(context).pop(),
            radius: BottomSheetDimens.closeButton / 2,
            child: Container(
              width: BottomSheetDimens.closeButton,
              height: BottomSheetDimens.closeButton,
              decoration: BoxDecoration(
                color: colors.background,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppSvgIcon(
                AppAssets.close,
                size: BottomSheetDimens.closeIcon,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
