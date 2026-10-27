import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import 'app_text.dart';

/// A white card of [children] with an optional uppercase section [label] above it
/// (docs/specs/profile/02-components.md SettingsGroup).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.label, required this.children});

  final String? label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: SettingsDimens.labelTop,
              start: SettingsDimens.labelSide,
              end: SettingsDimens.labelSide,
              bottom: SettingsDimens.labelBottom,
            ),
            child: Semantics(
              header: true,
              child: AppText(
                label!.toUpperCase(),
                style: context.text.section,
                color: colors.textSecondary,
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Padding(
              padding: EdgeInsets.all(SettingsDimens.groupPadding),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }
}
