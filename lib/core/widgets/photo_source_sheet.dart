import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../extensions/l10n.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';
import '../enums/photo_choice.dart';

/// The bottom sheet behind the photo picker (docs/specs/auth/02-components.md C13): a grabber, a title,
/// then Take photo, Choose from gallery and, when a photo is set, Remove photo as icon cards.
abstract final class PhotoSourceSheet {
  /// The chosen [PhotoChoice], or null when the sheet was dismissed.
  static Future<PhotoChoice?> show(
    BuildContext context, {
    required bool hasPhoto,
  }) {
    final colors = context.appColors;
    return showModalBottomSheet<PhotoChoice>(
      context: context,
      backgroundColor: colors.surface,
      barrierColor: colors.scrim,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheetTop),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.formSide,
            0,
            AppSpacing.formSide,
            AppSpacing.s16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                context.l10n.photoSheetTitle,
                style: context.text.name,
                color: colors.textPrimary,
              ),
              SizedBox(height: AppSpacing.s16),
              for (final choice in PhotoChoice.values)
                if (choice != PhotoChoice.remove || hasPhoto) ...[
                  _Option(choice: choice),
                  SizedBox(height: AppSpacing.s12),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.choice});

  final PhotoChoice choice;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isRemove = choice == PhotoChoice.remove;
    final color = isRemove ? colors.danger : colors.primary;
    final radius = BorderRadius.circular(AppRadius.settingsTile);
    return Material(
      color: colors.surfaceMuted,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => Navigator.of(context).pop(choice),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AuthDimens.tapTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s12,
            ),
            child: Row(
              children: [
                Container(
                  width: DialogDimens.iconCircle,
                  height: DialogDimens.iconCircle,
                  decoration: BoxDecoration(
                    color: isRemove ? colors.dangerSoft : colors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AppSvgIcon(
                    choice.icon,
                    size: DialogDimens.icon,
                    color: color,
                  ),
                ),
                SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: AppText(
                    choice.l10n(context),
                    style: context.text.name,
                    color: isRemove ? colors.danger : colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
