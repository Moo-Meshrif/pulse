import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../utils/password_rule.dart';

/// The reset screen's rule rows (docs/specs/auth/02-components.md C8b). Each row reads "RULE, met" or
/// "RULE, not met" for screen readers.
class PasswordRulesList extends StatelessWidget {
  const PasswordRulesList({super.key, required this.rules});

  final List<PasswordRule> rules;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AuthDimens.ruleRowGap,
      children: [
        for (final rule in rules)
          Semantics(
            excludeSemantics: true,
            label: rule.met
                ? context.l10n.ruleMet(rule.label)
                : context.l10n.ruleNotMet(rule.label),
            child: Row(
              children: [
                SizedBox(
                  width: AuthDimens.ruleIconSlot,
                  child: Center(
                    child: rule.met
                        ? AppSvgIcon(
                            AppAssets.check,
                            size: AuthDimens.ruleCheck,
                            color: colors.primary,
                          )
                        : Container(
                            width: AuthDimens.ruleDot,
                            height: AuthDimens.ruleDot,
                            decoration: BoxDecoration(
                              color: colors.dashed,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: AuthDimens.ruleIconGap),
                Expanded(
                  child: AppText(
                    rule.label,
                    style: context.text.caption,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
