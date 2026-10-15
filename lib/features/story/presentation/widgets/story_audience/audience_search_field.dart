import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/story_dimens.dart';

/// The search box of a list screen.
class AudienceSearchField extends StatelessWidget {
  const AudienceSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hint = context.l10n.storyAudienceSearch;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.darkSurfaceRow,
        borderRadius: BorderRadius.circular(OptionSheetDimens.groupRadius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: StoryCameraDimens.topBarHeight),
        child: Row(
          children: [
            SizedBox(width: AppSpacing.s12),
            AppSvgIcon(
              AppAssets.search,
              size: OptionSheetDimens.rowIcon,
              color: colors.onDark.withValues(alpha: DarkOpacity.chevron),
            ),
            SizedBox(width: AppSpacing.s8),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                cursorColor: colors.onDark,
                style: context.text.body.copyWith(
                  textBaseline: TextBaseline.alphabetic,
                  color: colors.onDark,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: context.text.body.copyWith(
                    textBaseline: TextBaseline.alphabetic,
                    color: colors.onDark.withValues(
                      alpha: DarkOpacity.subtitle,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.s12),
          ],
        ),
      ),
    );
  }
}
