import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/enums/sheet_tone.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/story_dimens.dart';

/// A destructive confirmation on the dark story surface (docs/specs/story/screens/s6-viewer-menus.md,
/// panel 10): the delete dialog and the edit screen's discard dialog. Resolves true when confirmed.
abstract final class StoryConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    required String cancelLabel,
    String icon = AppAssets.trash,
    bool isDestructive = true,
  }) async {
    final confirmed = await AppDialogShell.show<bool>(
      context,
      tone: SheetTone.dark,
      builder: (_) => AppDialogShell(
        semanticLabel: title,
        tone: SheetTone.dark,
        padding: StorySheetDimens.dialogPadding,
        margin: StorySheetDimens.dialogMargin,
        radius: StorySheetDimens.dialogRadius,
        child: _Content(
          title: title,
          body: body,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          icon: icon,
          isDestructive: isDestructive,
        ),
      ),
    );
    return confirmed ?? false;
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.icon,
    required this.isDestructive,
  });

  final String icon;

  /// A red Delete-style button; otherwise a white one.
  final bool isDestructive;
  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: AppSvgIcon(
            icon,
            size: StorySheetDimens.dialogIcon,
            color: isDestructive ? colors.dangerOnDark : colors.onDark,
          ),
        ),
        SizedBox(height: StorySheetDimens.dialogTitleTop),
        AppText(
          title,
          style: context.text.titleSm,
          color: colors.onDark,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: StorySheetDimens.dialogBodyTop),
        AppText(
          body,
          style: context.text.bodySm,
          color: colors.onDark.withValues(alpha: DarkOpacity.dialogBody),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: StorySheetDimens.dialogDeleteTop),
        SizedBox(
          height: StorySheetDimens.dialogDeleteHeight,
          child: FilledButton(
            onPressed: () => AppNavigator.back(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: isDestructive ? colors.danger : colors.onDark,
              foregroundColor: isDestructive
                  ? colors.textOnPrimary
                  : colors.textPrimary,
            ),
            child: AppText(
              confirmLabel,
              style: context.text.button,
              color: isDestructive ? colors.textOnPrimary : colors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: StorySheetDimens.dialogCancelHeight,
          child: TextButton(
            autofocus: true,
            onPressed: () => AppNavigator.back(context, false),
            child: AppText(
              cancelLabel,
              style: context.text.name,
              color: colors.onDark.withValues(alpha: DarkOpacity.link),
            ),
          ),
        ),
      ],
    );
  }
}

/// "Delete this story?" with the view count (docs/specs/story/screens/s6-viewer-menus.md, panel 10).
abstract final class StoryDeleteDialog {
  static Future<bool> show(BuildContext context, {required int viewCount}) {
    final l10n = context.l10n;
    return StoryConfirmDialog.show(
      context,
      title: l10n.storyDeleteTitle,
      body: l10n.storyDeleteBody(viewCount),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
  }
}
