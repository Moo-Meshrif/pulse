import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../enums/permission_access.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/l10n.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import '../app_svg_icon.dart';
import '../app_text.dart';

/// The Camera / Microphone card: each row says Needed, a green check (allowed) or an amber Off.
class PermissionStatusCard extends StatelessWidget {
  const PermissionStatusCard({
    super.key,
    required this.camera,
    required this.microphone,
  });

  final PermissionAccess camera;
  final PermissionAccess microphone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: StoryPermissionDimens.cardMaxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.storyOnDark.withValues(alpha: StoryOpacity.cardFill),
          borderRadius: BorderRadius.circular(StoryPermissionDimens.cardRadius),
        ),
        child: Column(
          children: [
            _Row(
              icon: AppAssets.camera,
              label: l10n.permCamera,
              access: camera,
            ),
            Divider(
              height: StorySheetDimens.separator,
              thickness: StorySheetDimens.separator,
              color: colors.storyOnDark.withValues(
                alpha: StoryOpacity.separator,
              ),
            ),
            _Row(
              icon: AppAssets.mic,
              label: l10n.permMicrophone,
              access: microphone,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.access});

  final String icon;
  final String label;
  final PermissionAccess access;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final (String state, Widget trailing) = switch (access) {
      PermissionAccess.granted => (
        l10n.permAllowed,
        Container(
          width: StoryPermissionDimens.okCircle,
          height: StoryPermissionDimens.okCircle,
          decoration: BoxDecoration(
            color: colors.storySuccess,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: AppSvgIcon(
            AppAssets.check,
            size: StoryPermissionDimens.okCircle * 0.6,
            color: colors.textPrimary,
          ),
        ),
      ),
      PermissionAccess.blocked || PermissionAccess.restricted => (
        l10n.permOff,
        AppText(
          l10n.permOff,
          style: context.text.countLabel,
          color: colors.storyWarning,
        ),
      ),
      PermissionAccess.denied => (
        l10n.permNeeded,
        AppText(
          l10n.permNeeded,
          style: context.text.countLabel,
          color: colors.storyOnDark.withValues(alpha: StoryOpacity.subtitle),
        ),
      ),
    };
    return Semantics(
      label: '$label, $state',
      excludeSemantics: true,
      child: SizedBox(
        height: StoryPermissionDimens.cardRow,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12),
          child: Row(
            children: [
              Container(
                width: StoryPermissionDimens.tile,
                height: StoryPermissionDimens.tile,
                decoration: BoxDecoration(
                  color: colors.storyOnDark.withValues(
                    alpha: StoryOpacity.tileFill,
                  ),
                  borderRadius: BorderRadius.circular(
                    StoryPermissionDimens.tileRadius,
                  ),
                ),
                alignment: Alignment.center,
                child: AppSvgIcon(
                  icon,
                  size: StorySheetDimens.rowIcon,
                  color: colors.storyOnDark,
                ),
              ),
              SizedBox(width: AppSpacing.s12),
              Expanded(
                child: AppText(
                  label,
                  style: context.text.name,
                  color: colors.storyOnDark,
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
