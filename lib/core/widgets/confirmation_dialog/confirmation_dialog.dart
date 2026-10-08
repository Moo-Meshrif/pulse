import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import '../app_dialog_shell.dart';
import '../app_svg_icon.dart';
import '../app_text.dart';
import 'confirmation_strategy.dart';

/// Confirmation dialogs on [AppDialogShell] (docs/specs/auth/02-components.md C14). Each factory returns
/// `Future<bool?>`: true confirmed, false cancelled, null dismissed. The layout is fixed per factory
/// ([ConfirmationStrategy]); callers pass texts only.
abstract final class ConfirmationDialog {
  /// Danger icon; soft cancel (start) + danger confirm (end). Focus starts on cancel.
  static Future<bool?> destructive(
    BuildContext context, {
    required String icon,
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
  }) => _show(
    context,
    dismissible: true,
    content: _Content(
      strategy: const DestructiveStrategy(),
      icon: icon,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );

  /// Primary icon; soft cancel + primary confirm.
  static Future<bool?> primary(
    BuildContext context, {
    required String icon,
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
  }) => _show(
    context,
    dismissible: true,
    content: _Content(
      strategy: const PrimaryStrategy(),
      icon: icon,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );

  /// Primary icon; one full-width primary pill. [dismissible] false makes barrier tap and Android back
  /// do nothing (the password-updated dialog).
  static Future<bool?> info(
    BuildContext context, {
    required String icon,
    required String title,
    required String message,
    required String okLabel,
    bool dismissible = true,
  }) => _show(
    context,
    dismissible: dismissible,
    content: _Content(
      strategy: const InfoStrategy(),
      icon: icon,
      title: title,
      message: message,
      confirmLabel: okLabel,
    ),
  );

  /// No icon; confirm on top (danger by default, or primary), soft cancel below. For long labels.
  static Future<bool?> stacked(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    bool destructive = true,
  }) => _show(
    context,
    dismissible: true,
    content: _Content(
      strategy: StackedStrategy(destructive: destructive),
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );

  static Future<bool?> _show(
    BuildContext context, {
    required _Content content,
    required bool dismissible,
  }) => AppDialogShell.show<bool>(
    context,
    dismissible: dismissible,
    builder: (_) =>
        AppDialogShell(semanticLabel: content.title, child: content),
  );
}

/// The dialog body: optional icon circle, title, message, then the actions its [strategy] builds.
class _Content extends StatelessWidget {
  const _Content({
    required this.strategy,
    this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel,
  });

  final ConfirmationStrategy strategy;
  final String? icon;
  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final iconStyle = strategy.iconStyle(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (iconStyle != null) ...[
          Center(
            child: _IconCircle(icon: icon!, style: iconStyle),
          ),
          SizedBox(height: DialogDimens.iconToTitleGap),
        ],
        AppText(
          title,
          style: context.text.titleSm,
          color: colors.textPrimary,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DialogDimens.titleToMessageGap),
        AppText(
          message,
          style: context.text.bodySm,
          color: colors.textSecondary,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DialogDimens.messageToActionsGap),
        strategy.actions(
          context,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
        ),
      ],
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.style});

  final String icon;
  final ({Color fill, Color color}) style;

  @override
  Widget build(BuildContext context) => Container(
    width: DialogDimens.iconCircle,
    height: DialogDimens.iconCircle,
    decoration: BoxDecoration(color: style.fill, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: AppSvgIcon(icon, size: DialogDimens.icon, color: style.color),
  );
}
