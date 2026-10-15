import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../enums/permission_access.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/l10n.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/dimens/app_dimens.dart';
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
      constraints: BoxConstraints(
        maxWidth: CameraPermissionDimens.cardMaxWidth,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.onDark.withValues(alpha: DarkOpacity.cardFill),
          borderRadius: BorderRadius.circular(
            CameraPermissionDimens.cardRadius,
          ),
        ),
        child: Column(
          children: [
            _Row(
              icon: AppAssets.camera,
              label: l10n.permCamera,
              access: camera,
            ),
            Divider(
              color: colors.onDark.withValues(alpha: DarkOpacity.separator),
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
          width: CameraPermissionDimens.okCircle,
          height: CameraPermissionDimens.okCircle,
          decoration: BoxDecoration(
            color: colors.successOnDark,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: AppSvgIcon(
            AppAssets.check,
            size: CameraPermissionDimens.okCircle * 0.6,
            color: colors.textPrimary,
          ),
        ),
      ),
      PermissionAccess.blocked || PermissionAccess.restricted => (
        l10n.permOff,
        AppText(
          l10n.permOff,
          style: context.text.countLabel,
          color: colors.warningOnDark,
        ),
      ),
      PermissionAccess.denied => (
        l10n.permNeeded,
        AppText(
          l10n.permNeeded,
          style: context.text.countLabel,
          color: colors.onDark.withValues(alpha: DarkOpacity.subtitle),
        ),
      ),
    };
    return Semantics(
      label: '$label, $state',
      excludeSemantics: true,
      child: SizedBox(
        height: CameraPermissionDimens.cardRow,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12),
          child: Row(
            children: [
              Container(
                width: CameraPermissionDimens.tile,
                height: CameraPermissionDimens.tile,
                decoration: BoxDecoration(
                  color: colors.onDark.withValues(alpha: DarkOpacity.tileFill),
                  borderRadius: BorderRadius.circular(
                    CameraPermissionDimens.tileRadius,
                  ),
                ),
                alignment: Alignment.center,
                child: AppSvgIcon(
                  icon,
                  size: OptionSheetDimens.rowIcon,
                  color: colors.onDark,
                ),
              ),
              SizedBox(width: AppSpacing.s12),
              Expanded(
                child: AppText(
                  label,
                  style: context.text.name,
                  color: colors.onDark,
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
