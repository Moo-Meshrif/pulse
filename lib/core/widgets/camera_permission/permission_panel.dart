import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/l10n.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import '../app_safe_area.dart';
import '../app_svg_icon.dart';
import '../app_text.dart';
import 'permission_pill.dart';

/// The dark page every camera-permission panel is built on (docs/specs/story/source-tokens.md §7): a close
/// button at the start of the top, then icon, title, body, an optional [card] and the actions, centered.
class PermissionPanel extends StatelessWidget {
  const PermissionPanel({
    super.key,
    required this.icons,
    required this.title,
    required this.body,
    required this.onClose,
    this.card,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.linkLabel,
    this.onLink,
  });

  /// One icon (72) or two (56 each) with its color.
  final List<({String asset, Color? color})> icons;
  final String title;
  final String body;
  final VoidCallback onClose;
  final Widget? card;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? linkLabel;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final single = icons.length == 1;
    return Material(
      color: colors.textPrimary,
      child: AppSafeArea(
        bottomSpace: StoryPermissionDimens.bottomOffset,
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  StoryPermissionDimens.sidePadding,
                  StoryCameraDimens.roundControl,
                  StoryPermissionDimens.sidePadding,
                  StoryPermissionDimens.bottomOffset,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: StoryPermissionDimens.pairGap,
                      children: [
                        for (final icon in icons)
                          AppSvgIcon(
                            icon.asset,
                            size: single
                                ? StoryPermissionDimens.icon
                                : StoryPermissionDimens.pairIcon,
                            color: icon.color ?? colors.storyOnDark,
                          ),
                      ],
                    ),
                    SizedBox(height: StoryPermissionDimens.titleTop),
                    Semantics(
                      header: true,
                      child: AppText(
                        title,
                        style: context.text.title,
                        color: colors.storyOnDark,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: StoryPermissionDimens.bodyTop),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: StoryPermissionDimens.bodyMaxWidth,
                      ),
                      child: AppText(
                        body,
                        style: context.text.subtitle,
                        color: colors.storyOnDark.withValues(
                          alpha: StoryOpacity.dialogBody,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (card != null) ...[
                      SizedBox(height: AppSpacing.s24),
                      card!,
                    ],
                    SizedBox(height: AppSpacing.s32),
                    if (primaryLabel != null)
                      PermissionPill(
                        label: primaryLabel!,
                        onTap: onPrimary,
                        fill: colors.storyOnDark,
                        textColor: colors.textPrimary,
                      ),
                    if (secondaryLabel != null) ...[
                      SizedBox(height: AppSpacing.s12),
                      PermissionPill(
                        label: secondaryLabel!,
                        onTap: onSecondary,
                        fill: colors.storyOnDark.withValues(
                          alpha: StoryOpacity.secondaryFill,
                        ),
                        textColor: colors.storyOnDark,
                      ),
                    ],
                    if (linkLabel != null)
                      Semantics(
                        button: true,
                        excludeSemantics: true,
                        label: linkLabel,
                        child: InkWell(
                          onTap: onLink,
                          child: SizedBox(
                            height: StoryPermissionDimens.linkHeight,
                            child: Center(
                              child: AppText(
                                linkLabel!,
                                style: context.text.name,
                                color: colors.storyOnDark.withValues(
                                  alpha: StoryOpacity.link,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              top: 0,
              start: StoryCameraDimens.topBarSide,
              child: Semantics(
                button: true,
                label: context.l10n.close,
                excludeSemantics: true,
                child: InkResponse(
                  onTap: onClose,
                  child: SizedBox.square(
                    dimension: StoryCameraDimens.roundControl,
                    child: Center(
                      child: AppSvgIcon(
                        AppAssets.close,
                        size: StoryCameraDimens.closeIcon,
                        color: colors.storyOnDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
