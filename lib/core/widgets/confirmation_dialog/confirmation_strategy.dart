import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../../router/app_navigator.dart';
import '../../theme/app_dimens.dart';
import '../pill_button.dart';
import '../primary_button.dart';

/// The Strategy behind the [ConfirmationDialog] factories: it supplies the icon style and actions, so a new
/// kind is a new subclass, not another branch.
sealed class ConfirmationStrategy {
  const ConfirmationStrategy();

  /// The icon circle's colors, or null when this kind has no icon.
  ({Color fill, Color color})? iconStyle(BuildContext context);

  /// The action area. [cancelLabel] is null for a kind without a cancel action.
  Widget actions(
    BuildContext context, {
    required String confirmLabel,
    String? cancelLabel,
  });

  // The pieces the strategies share. A tap returns true (confirmed) or false (cancelled).

  Widget _primaryConfirm(BuildContext context, String label) => PrimaryButton(
    label: label,
    onPressed: () => AppNavigator.back(context, true),
    expand: true,
    buttonHeight: AuthButtonDimens.pillHeight,
  );

  Widget _dangerConfirm(BuildContext context, String label) =>
      PillButton.danger(
        label: label,
        onPressed: () => AppNavigator.back(context, true),
      );

  Widget _cancel(
    BuildContext context,
    String label, {
    bool autofocus = false,
  }) => PillButton.soft(
    label: label,
    autofocus: autofocus,
    onPressed: () => AppNavigator.back(context, false),
  );

  /// Cancel at the start, confirm at the end, equal width; the Row mirrors in RTL.
  Widget _row(Widget cancel, Widget confirm) => Row(
    spacing: DialogDimens.actionGap,
    children: [
      Expanded(child: cancel),
      Expanded(child: confirm),
    ],
  );

  ({Color fill, Color color}) _primaryIcon(BuildContext context) =>
      (fill: context.appColors.primarySoft, color: context.appColors.primary);
}

/// Danger icon; soft cancel (start) + danger confirm (end). Focus starts on cancel.
class DestructiveStrategy extends ConfirmationStrategy {
  const DestructiveStrategy();

  @override
  ({Color fill, Color color})? iconStyle(BuildContext context) =>
      (fill: context.appColors.dangerSoft, color: context.appColors.danger);

  @override
  Widget actions(
    BuildContext context, {
    required String confirmLabel,
    String? cancelLabel,
  }) => _row(
    _cancel(context, cancelLabel!, autofocus: true),
    _dangerConfirm(context, confirmLabel),
  );
}

/// Primary icon; soft cancel + primary confirm.
class PrimaryStrategy extends ConfirmationStrategy {
  const PrimaryStrategy();

  @override
  ({Color fill, Color color})? iconStyle(BuildContext context) =>
      _primaryIcon(context);

  @override
  Widget actions(
    BuildContext context, {
    required String confirmLabel,
    String? cancelLabel,
  }) => _row(
    _cancel(context, cancelLabel!),
    _primaryConfirm(context, confirmLabel),
  );
}

/// Primary icon; one full-width primary action.
class InfoStrategy extends ConfirmationStrategy {
  const InfoStrategy();

  @override
  ({Color fill, Color color})? iconStyle(BuildContext context) =>
      _primaryIcon(context);

  @override
  Widget actions(
    BuildContext context, {
    required String confirmLabel,
    String? cancelLabel,
  }) => _primaryConfirm(context, confirmLabel);
}

/// No icon; confirm on top (danger or primary), soft cancel below, for long labels.
class StackedStrategy extends ConfirmationStrategy {
  const StackedStrategy({required this.destructive});

  final bool destructive;

  @override
  ({Color fill, Color color})? iconStyle(BuildContext context) => null;

  @override
  Widget actions(
    BuildContext context, {
    required String confirmLabel,
    String? cancelLabel,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: DialogDimens.stackedActionGap,
    children: [
      destructive
          ? _dangerConfirm(context, confirmLabel)
          : _primaryConfirm(context, confirmLabel),
      _cancel(context, cancelLabel!, autofocus: destructive),
    ],
  );
}
