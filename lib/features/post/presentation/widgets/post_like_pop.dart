import 'package:flutter/material.dart';

import '../dimens/post_card_dimens.dart';

/// Pops its child when [isLiked] turns true.
class PostLikePop extends StatefulWidget {
  const PostLikePop({super.key, required this.isLiked, required this.child});

  final bool isLiked;
  final Widget child;

  @override
  State<PostLikePop> createState() => PostLikePopState();
}

class PostLikePopState extends State<PostLikePop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PostMotion.likePop,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: PostMotion.likeRestScale,
        end: PostMotion.likePopScale,
      ),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: PostMotion.likePopScale,
        end: PostMotion.likeRestScale,
      ),
      weight: 1,
    ),
  ]).animate(_controller);

  @override
  void didUpdateWidget(PostLikePop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked && !oldWidget.isLiked) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}
