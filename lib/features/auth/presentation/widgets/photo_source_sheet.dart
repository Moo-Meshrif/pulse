import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../utils/enums/photo_choice.dart';

/// The bottom sheet behind the photo picker (docs/specs/auth/02-components.md C13): Take photo, Choose
/// from gallery and, when a photo is set, Remove photo.
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheetTop),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final choice in PhotoChoice.values)
                if (choice != PhotoChoice.remove || hasPhoto)
                  _Option(choice: choice),
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
    final color = choice == PhotoChoice.remove
        ? colors.danger
        : colors.textPrimary;
    return InkWell(
      onTap: () => Navigator.of(context).pop(choice),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AuthDimens.tapTarget),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.formSide,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            children: [
              AppSvgIcon(
                choice.icon,
                size: AuthDimens.stepBarIcon,
                color: color,
              ),
              SizedBox(width: AppSpacing.s16),
              Expanded(
                child: AppText(
                  choice.l10n(context),
                  style: context.text.name,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
