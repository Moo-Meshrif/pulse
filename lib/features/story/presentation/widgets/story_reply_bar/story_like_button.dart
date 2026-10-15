import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../dimens/story_constants.dart';
import '../../dimens/story_dimens.dart';
import 'story_action_button.dart';

class StoryLikeButton extends StatefulWidget {
  const StoryLikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
  });

  final bool isLiked;
  final VoidCallback onTap;

  @override
  State<StoryLikeButton> createState() => _StoryLikeButtonState();
}

class _StoryLikeButtonState extends State<StoryLikeButton>
    with SingleTickerProviderStateMixin {
  late final _pop = AnimationController(
    vsync: this,
    duration: StoryMotion.likePop,
  );

  @override
  void didUpdateWidget(StoryLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked &&
        !oldWidget.isLiked &&
        !MediaQuery.disableAnimationsOf(context)) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: StoryMotion.likeRestScale,
          end: StoryMotion.likePopScale,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: StoryMotion.likePopScale,
          end: StoryMotion.likeRestScale,
        ),
        weight: 1,
      ),
    ]).animate(_pop);
    return ScaleTransition(
      scale: scale,
      child: StoryActionButton(
        asset: widget.isLiked ? AppAssets.heartFilled : AppAssets.heart,
        label: widget.isLiked
            ? context.l10n.storyUnlike
            : context.l10n.storyLike,
        size: StoryDimens.likeIcon,
        color: widget.isLiked ? colors.like : null,
        onTap: widget.onTap,
      ),
    );
  }
}
