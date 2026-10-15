import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_options_dimens.dart';

/// The amber note on a private account, with its "Privacy settings" link.
class VisibilityPrivateNote extends StatelessWidget {
  const VisibilityPrivateNote({super.key, required this.onPrivacySettings});

  final VoidCallback onPrivacySettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: colors.warningSoft,
        borderRadius: BorderRadius.circular(VisibilityDimens.noteRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSvgIcon(
            AppAssets.warning,
            size: VisibilityDimens.tileIcon,
            color: colors.warningText,
          ),
          SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: context.text.bodySm.copyWith(color: colors.warningText),
                children: [
                  TextSpan(text: '${l10n.postVisibilityPrivateNote} '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: onPrivacySettings,
                      child: Semantics(
                        link: true,
                        child: Text(
                          l10n.postVisibilityPrivacySettings,
                          style: context.text.bodySm.copyWith(
                            color: colors.warningText,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
