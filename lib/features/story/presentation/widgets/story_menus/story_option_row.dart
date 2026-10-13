import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';

/// A rounded card of option rows on the dark story sheet, rows separated by a hairline.
class StoryOptionGroup extends StatelessWidget {
  const StoryOptionGroup({super.key, required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(StorySheetDimens.groupRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.storySheetRow),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, row) in rows.indexed) ...[
              if (i > 0)
                Divider(
                  height: StorySheetDimens.separator,
                  thickness: StorySheetDimens.separator,
                  color: colors.storyOnDark.withValues(
                    alpha: StoryOpacity.separator,
                  ),
                ),
              row,
            ],
          ],
        ),
      ),
    );
  }
}

class StoryOptionRow extends StatelessWidget {
  const StoryOptionRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDanger = false,
    this.showsChevron = false,
    this.onTap,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final bool isDanger;

  /// A chevron at the end: the row opens another screen.
  final bool showsChevron;

  /// Null makes a read-only row: no ripple, no chevron.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.text;
    final color = isDanger ? colors.dangerOnDark : colors.storyOnDark;
    return Semantics(
      button: onTap != null,
      excludeSemantics: true,
      label: subtitle == null ? title : '$title, $subtitle',
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: StorySheetDimens.rowMinHeight,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: StorySheetDimens.rowPaddingH,
              vertical: StorySheetDimens.rowPaddingV,
            ),
            child: Row(
              children: [
                AppSvgIcon(icon, size: StorySheetDimens.rowIcon, color: color),
                SizedBox(width: StorySheetDimens.rowGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(title, style: text.body, color: color),
                      if (subtitle != null)
                        AppText(
                          subtitle!,
                          style: text.caption,
                          color: colors.storyOnDark.withValues(
                            alpha: StoryOpacity.subtitle,
                          ),
                        ),
                    ],
                  ),
                ),
                if (showsChevron)
                  AppSvgIcon(
                    AppAssets.chevronRight,
                    size: StorySheetDimens.chevron,
                    color: colors.storyOnDark.withValues(
                      alpha: StoryOpacity.chevron,
                    ),
                    directional: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
