import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'story_action_button.dart';
import 'story_like_button.dart';

class StoryReplyBar extends StatefulWidget {
  const StoryReplyBar({
    super.key,
    required this.isLiked,
    required this.onLike,
    required this.onSend,
    required this.onFocusChanged,
  });

  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onSend;

  /// The reply field gained or lost focus (its keyboard pauses the story).
  final ValueChanged<bool> onFocusChanged;

  @override
  State<StoryReplyBar> createState() => _StoryReplyBarState();
}

class _StoryReplyBarState extends State<StoryReplyBar> {
  final _focus = FocusNode();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => widget.onFocusChanged(_focus.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.text;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: StoryDimens.replyHeight,
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => widget.onSend(),
              style: text.body.copyWith(
                color: colors.storyOnDark,
                textBaseline: TextBaseline.alphabetic, // TextField asserts on it when inherit is false
              ),
              cursorColor: colors.storyOnDark,
              decoration: InputDecoration(
                hintText: context.l10n.storyReplyHint,
                hintStyle: text.body.copyWith(
                  color: colors.storyOnDark.withValues(
                    alpha: StoryOpacity.replyHint,
                  ),
                  textBaseline: TextBaseline.alphabetic,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: StoryDimens.replyPadding,
                ),
                enabledBorder: _border(
                  colors.storyOnDark.withValues(
                    alpha: StoryOpacity.replyBorder,
                  ),
                ),
                focusedBorder: _border(colors.storyOnDark),
              ),
            ),
          ),
        ),
        SizedBox(width: StoryDimens.replyGap),
        // The heart while the field is empty, the send icon once there is something to send.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => value.text.trim().isEmpty
              ? StoryLikeButton(isLiked: widget.isLiked, onTap: widget.onLike)
              : StoryActionButton(
                  asset: AppAssets.share,
                  label: context.l10n.storySend,
                  size: StoryDimens.sendIcon,
                  onTap: widget.onSend,
                  isDirectional: true,
                ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(
      AppRadius.pill(StoryDimens.replyHeight),
    ),
    borderSide: BorderSide(color: color, width: StoryDimens.replyBorder),
  );
}
