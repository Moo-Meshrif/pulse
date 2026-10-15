import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_options_dimens.dart';
import 'visibility_radio.dart';

/// One audience in the picker: an icon tile, the title with its words under it, an optional Edit pill and
/// the radio. A disabled row is greyed and ignores taps.
class VisibilityOptionRow extends StatelessWidget {
  const VisibilityOptionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.enabled = true,
    this.onEdit,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  /// Shows the Edit pill before the radio.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ink = enabled ? colors.textPrimary : colors.dashed;
    final label = subtitle == null ? title : '$title, $subtitle';
    final choice = Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: VisibilityDimens.rowPadding,
          child: Row(
            children: [
              Container(
                width: VisibilityDimens.tile,
                height: VisibilityDimens.tile,
                decoration: BoxDecoration(
                  color: selected ? colors.primarySoft : colors.surface,
                  borderRadius: BorderRadius.circular(
                    VisibilityDimens.tileRadius,
                  ),
                ),
                alignment: Alignment.center,
                child: AppSvgIcon(
                  icon,
                  size: VisibilityDimens.tileIcon,
                  color: selected ? colors.primary : ink,
                ),
              ),
              SizedBox(width: VisibilityDimens.rowGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(title, style: context.text.name, color: ink),
                    if (subtitle != null)
                      AppText(
                        subtitle!,
                        style: context.text.caption,
                        color: enabled ? colors.textSecondary : colors.dashed,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: VisibilityDimens.rowMinHeight),
      child: Row(
        children: [
          Expanded(child: choice),
          if (onEdit != null) _EditPill(onTap: onEdit!),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.s12,
              end: VisibilityDimens.rowPadding.right,
            ),
            child: ExcludeSemantics(
              child: VisibilityRadio(selected: selected, enabled: enabled),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditPill extends StatelessWidget {
  const _EditPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = context.l10n.postVisibilityEdit;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      child: Material(
        color: colors.primarySoft,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: VisibilityDimens.editPillHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              child: Center(
                widthFactor: 1,
                child: AppText(
                  label,
                  style: context.text.label,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
