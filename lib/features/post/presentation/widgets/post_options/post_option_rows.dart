import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_options_dimens.dart';
import '../../utils/enums/post_option.dart';
import '../../utils/post_options_data.dart';

/// One of the three tiles at the top of the sheet.
class PostQuickTile extends StatelessWidget {
  const PostQuickTile({
    super.key,
    required this.option,
    required this.data,
    required this.onTap,
  });

  final PostOption option;
  final PostOptionsData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final title = option.title(context, data);
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: title,
      child: Material(
        color: colors.background,
        borderRadius: BorderRadius.circular(PostOptionsDimens.quickTileRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(
            PostOptionsDimens.quickTileRadius,
          ),
          onTap: onTap,
          child: SizedBox(
            height: PostOptionsDimens.quickTileHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSvgIcon(
                  option.icon(data),
                  size: PostOptionsDimens.quickTileIcon,
                  color: colors.textPrimary,
                ),
                SizedBox(height: AppSpacing.s4),
                AppText(
                  title,
                  style: context.text.label,
                  color: colors.textPrimary,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded card of option rows, separated by a hairline.
class PostOptionGroup extends StatelessWidget {
  const PostOptionGroup({
    super.key,
    required this.options,
    required this.data,
    required this.onPick,
  });

  final List<PostOption> options;
  final PostOptionsData data;
  final ValueChanged<PostOption> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(PostOptionsDimens.groupRadius),
      child: ColoredBox(
        color: colors.background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, option) in options.indexed) ...[
              if (i > 0) const Divider(),
              _PostOptionRow(
                option: option,
                data: data,
                onTap: () => onPick(option),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PostOptionRow extends StatelessWidget {
  const _PostOptionRow({
    required this.option,
    required this.data,
    required this.onTap,
  });

  final PostOption option;
  final PostOptionsData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = option.isDanger ? colors.danger : colors.textPrimary;
    final title = option.title(context, data);
    final hint = option.hint(context);
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: hint == null ? title : '$title, $hint',
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: PostOptionsDimens.rowMinHeight,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Row(
              children: [
                AppSvgIcon(
                  option.icon(data),
                  size: PostOptionsDimens.rowIcon,
                  color: color,
                ),
                SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(title, style: context.text.body, color: color),
                      if (hint != null)
                        AppText(
                          hint,
                          style: context.text.caption,
                          color: colors.textSecondary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
