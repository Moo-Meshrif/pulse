import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/comments_dimens.dart';
import '../../utils/comment_option_layout.dart';
import '../../utils/comment_text.dart';
import '../../utils/enums/comment_option.dart';

/// What the long-press menu answered: a row, or a quick emoji.
typedef CommentMenuChoice = ({CommentOption? option, String? emoji});

/// The long-press menu of a comment (docs/specs/post/screens/s14-comments-sheet.md, panels 3 and 4): six
/// quick emoji and the rows of [CommentOptionLayout]. Pops with the [CommentMenuChoice].
class CommentOptionsSheet extends StatelessWidget {
  const CommentOptionsSheet({super.key, required this.layout});

  final CommentOptionLayout layout;

  /// Resolves with the choice, or null when the sheet was dismissed.
  static Future<CommentMenuChoice?> show(
    BuildContext context,
    CommentOptionLayout layout,
  ) => AppBottomSheet.show<CommentMenuChoice>(
    context,
    child: CommentOptionsSheet(layout: layout),
  );

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: CommentsDimens.menuGap,
      children: [
        if (layout.showEmoji)
          _QuickEmoji(
            onPick: (emoji) =>
                AppNavigator.back(context, (option: null, emoji: emoji)),
          ),
        for (final group in [layout.groupA, layout.groupB])
          if (group.isNotEmpty)
            _Group(
              options: group,
              onPick: (option) =>
                  AppNavigator.back(context, (option: option, emoji: null)),
            ),
      ],
    ),
  );
}

class _QuickEmoji extends StatelessWidget {
  const _QuickEmoji({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final emoji in CommentText.menuEmoji)
        Expanded(
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: emoji,
            child: InkResponse(
              onTap: () => onPick(emoji),
              radius: CommentsDimens.menuEmojiTarget / 2,
              child: SizedBox(
                height: CommentsDimens.menuEmojiTarget,
                child: Center(
                  child: Container(
                    width: CommentsDimens.menuEmojiCircle,
                    height: CommentsDimens.menuEmojiCircle,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.appColors.background,
                    ),
                    child: Text(
                      emoji,
                      style: context.text.input.copyWith(
                        fontSize: CommentsDimens.menuEmoji,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.options, required this.onPick});

  final List<CommentOption> options;
  final ValueChanged<CommentOption> onPick;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(CommentsDimens.menuGroupRadius),
    child: ColoredBox(
      color: context.appColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, option) in options.indexed) ...[
            if (i > 0) const Divider(),
            _Row(option: option, onTap: () => onPick(option)),
          ],
        ],
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.option, required this.onTap});

  final CommentOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = option.isDanger ? colors.danger : colors.textPrimary;
    final title = option.title(context);
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: title,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: CommentsDimens.menuRowMinHeight,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Row(
              children: [
                AppSvgIcon(
                  option.icon,
                  size: CommentsDimens.menuRowIcon,
                  color: color,
                ),
                SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: AppText(title, style: context.text.body, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
