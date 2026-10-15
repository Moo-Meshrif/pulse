import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/l10n.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/dimens/app_dimens.dart';
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
        bottomSpace: CameraPermissionDimens.bottomOffset,
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  CameraPermissionDimens.sidePadding,
                  CameraPermissionDimens.roundControl,
                  CameraPermissionDimens.sidePadding,
                  CameraPermissionDimens.bottomOffset,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: CameraPermissionDimens.pairGap,
                      children: [
                        for (final icon in icons)
                          AppSvgIcon(
                            icon.asset,
                            size: single
                                ? CameraPermissionDimens.icon
                                : CameraPermissionDimens.pairIcon,
                            color: icon.color ?? colors.onDark,
                          ),
                      ],
                    ),
                    SizedBox(height: CameraPermissionDimens.titleTop),
                    Semantics(
                      header: true,
                      child: AppText(
                        title,
                        style: context.text.title,
                        color: colors.onDark,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: CameraPermissionDimens.bodyTop),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: CameraPermissionDimens.bodyMaxWidth,
                      ),
                      child: AppText(
                        body,
                        style: context.text.subtitle,
                        color: colors.onDark.withValues(
                          alpha: DarkOpacity.dialogBody,
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
                        fill: colors.onDark,
                        textColor: colors.textPrimary,
                      ),
                    if (secondaryLabel != null) ...[
                      SizedBox(height: AppSpacing.s12),
                      PermissionPill(
                        label: secondaryLabel!,
                        onTap: onSecondary,
                        fill: colors.onDark.withValues(
                          alpha: DarkOpacity.secondaryFill,
                        ),
                        textColor: colors.onDark,
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
                            height: CameraPermissionDimens.linkHeight,
                            child: Center(
                              child: AppText(
                                linkLabel!,
                                style: context.text.name,
                                color: colors.onDark.withValues(
                                  alpha: DarkOpacity.link,
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
              start: CameraPermissionDimens.topBarSide,
              child: Semantics(
                button: true,
                label: context.l10n.close,
                excludeSemantics: true,
                child: InkResponse(
                  onTap: onClose,
                  child: SizedBox.square(
                    dimension: CameraPermissionDimens.roundControl,
                    child: Center(
                      child: AppSvgIcon(
                        AppAssets.close,
                        size: CameraPermissionDimens.closeIcon,
                        color: colors.onDark,
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
