import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/l10n.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/dimens/app_dimens.dart';
import '../app_svg_icon.dart';
import '../app_text.dart';
import '../tinted_chip.dart';

/// Panel 3: "Microphone off · videos will be silent" with a Fix chip, drawn under the camera's header when
/// only the microphone is refused. Photo-only flows (profile photo) do not show it.
class MicOffPill extends StatelessWidget {
  const MicOffPill({super.key, required this.onFix});

  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.micOffPill,
        borderRadius: BorderRadius.circular(
          CameraPermissionDimens.micPillHeight,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: CameraPermissionDimens.micPillHeight,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.s12,
            end: AppSpacing.s8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSvgIcon(
                AppAssets.micOff,
                size: CameraPermissionDimens.micPillIcon,
                color: colors.warningOnDark,
              ),
              SizedBox(width: AppSpacing.s8),
              Flexible(
                child: AppText(
                  context.l10n.permMicOffPill,
                  style: context.text.label,
                  color: colors.onDark,
                ),
              ),
              SizedBox(width: AppSpacing.s8),
              TintedChip(
                label: context.l10n.permFix,
                color: colors.fixChipText,
                onTap: onFix,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
