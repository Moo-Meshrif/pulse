import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_options_dimens.dart';
import '../../utils/enums/post_option.dart';
import '../../utils/post_option_layout.dart';
import '../../utils/post_options_data.dart';
import 'post_option_rows.dart';

/// The "···" sheet of a post (docs/specs/post/screens/s2-post-options.md, panels 1 and 2): pops with the
/// [PostOption] picked. Someone's post offers not interested, unfollow, mute and report; yours offers edit
/// caption, who can see, comments and delete.
class PostOptionsSheet extends StatelessWidget {
  const PostOptionsSheet({super.key, required this.data});

  final PostOptionsData data;

  /// Resolves with the option picked, or null when the sheet was dismissed.
  static Future<PostOption?> show(BuildContext context, PostOptionsData data) =>
      AppBottomSheet.show<PostOption>(
        context,
        child: PostOptionsSheet(data: data),
      );

  void _pick(BuildContext context, PostOption option) =>
      AppNavigator.back(context, option);

  @override
  Widget build(BuildContext context) {
    final layout = PostOptionLayout.of(data);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: PostOptionsDimens.groupGap,
        children: [
          if (data.iAmTagged && !data.isMine) const _TaggedLine(),
          if (layout.quick.isNotEmpty)
            Row(
              spacing: PostOptionsDimens.quickGap,
              children: [
                for (final option in layout.quick)
                  Expanded(
                    child: PostQuickTile(
                      option: option,
                      data: data,
                      onTap: () => _pick(context, option),
                    ),
                  ),
              ],
            ),
          PostOptionGroup(
            options: layout.groupA,
            data: data,
            onPick: (option) => _pick(context, option),
          ),
          PostOptionGroup(
            options: layout.groupB,
            data: data,
            onPick: (option) => _pick(context, option),
          ),
        ],
      ),
    );
  }
}

/// "You're tagged in this post", over the options of a post you were tagged in.
class _TaggedLine extends StatelessWidget {
  const _TaggedLine();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      spacing: PostOptionsDimens.taggedLineGap,
      children: [
        AppSvgIcon(
          AppAssets.user,
          size: PostOptionsDimens.taggedLineIcon,
          color: colors.primary,
        ),
        Expanded(
          child: AppText(
            context.l10n.postTagYoureTagged,
            style: context.text.label,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
