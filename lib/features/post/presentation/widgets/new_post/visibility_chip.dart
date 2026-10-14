import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../shared/content/data/enums/content_audience.dart';
import '../../utils/content_audience_display.dart';

/// Who can see the post: the choice's icon and name with a chevron. Tapping it will open the picker
/// (docs/specs/post/screens/s4-visibility.md).
class VisibilityChip extends StatelessWidget {
  const VisibilityChip({
    super.key,
    required this.audience,
    this.isNarrowed = false,
    this.onTap,
  });

  final ContentAudience audience;

  /// Narrower than the account's default: `primarySoft` fill with a `primary` border and ink.
  final bool isNarrowed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = audience.label(context);
    final ink = isNarrowed ? colors.primary : colors.textPrimary;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: context.l10n.newPostVisibilityLabel(label),
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: PostComposerDimens.chipHeight,
          padding: EdgeInsets.symmetric(
            horizontal: PostComposerDimens.chipPadding,
          ),
          decoration: BoxDecoration(
            color: isNarrowed ? colors.primarySoft : colors.background,
            borderRadius: BorderRadius.circular(
              PostComposerDimens.chipHeight / 2,
            ),
            border: Border.all(
              color: isNarrowed ? colors.primary : colors.border,
              width: isNarrowed
                  ? PostComposerDimens.chipNarrowBorderWidth
                  : PostComposerDimens.chipBorderWidth,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSvgIcon(
                audience.icon,
                size: PostComposerDimens.chipIcon,
                color: ink,
              ),
              SizedBox(width: PostComposerDimens.chipGap),
              AppText(label, style: context.text.chip, color: ink),
              SizedBox(width: PostComposerDimens.chipGap),
              AppSvgIcon(
                AppAssets.chevronDown,
                size: PostComposerDimens.chipChevron,
                color: isNarrowed ? colors.primary : colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
