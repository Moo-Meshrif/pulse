import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../cubit/story_edit_cubit.dart';

/// Typing a text sticker over the dimmed edit screen. Resolves with the words (the "Done" button, or
/// tapping outside), or null when nothing was typed.
abstract final class StoryTextEditor {
  static Future<String?> show(BuildContext context, {String initial = ''}) =>
      showGeneralDialog<String>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        barrierLabel: context.l10n.storyToolText,
        barrierColor: context.appColors.storyBlack.withValues(
          alpha: StoryOpacity.dialogScrim,
        ),
        transitionDuration: StoryMotion.uiFade,
        pageBuilder: (_, _, _) => _Editor(initial: initial),
      );
}

class _Editor extends StatefulWidget {
  const _Editor({required this.initial});

  final String initial;

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() => AppNavigator.back(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      type: MaterialType.transparency,
      child: AppSafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Semantics(
                button: true,
                label: context.l10n.storyTextDone,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: _done,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s16),
                    child: AppText(
                      context.l10n.storyTextDone,
                      style: context.text.button,
                      color: colors.storyOnDark,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLength: StoryEditCubit.maxTextLength,
                    maxLines: null,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _done(),
                    cursorColor: colors.storyOnDark,
                    style: context.text.overlayText.copyWith(
                      // A TextField needs a baseline from a style that does not inherit.
                      textBaseline: TextBaseline.alphabetic,
                      color: colors.storyOnDark,
                      shadows: AppShadows.textOverlay,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      hintText: context.l10n.storyTextHint,
                      hintStyle: context.text.overlayText.copyWith(
                        color: colors.storyOnDark.withValues(
                          alpha: StoryOpacity.subtitle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
