import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/widgets/app_svg_icon.dart';
import '../../dimens/post_card_dimens.dart';

/// The big red heart of a double tap: it pops, then fades out. Call [PostHeartBurstState.play] on the key
/// to start it.
class PostHeartBurst extends StatefulWidget {
  const PostHeartBurst({super.key});

  @override
  State<PostHeartBurst> createState() => PostHeartBurstState();
}

class PostHeartBurstState extends State<PostHeartBurst>
    with SingleTickerProviderStateMixin {
  static const double _popWeight = 1;
  static const double _fadeWeight = 3;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PostMotion.heartPop + PostMotion.heartFade,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: PostMotion.heartStartScale,
        end: PostMotion.heartPeakScale,
      ),
      weight: _popWeight / 2,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: PostMotion.heartPeakScale,
        end: PostMotion.heartRestScale,
      ),
      weight: _popWeight / 2,
    ),
    TweenSequenceItem(
      tween: ConstantTween<double>(PostMotion.heartRestScale),
      weight: _fadeWeight,
    ),
  ]).animate(_controller);

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(
      tween: ConstantTween(PostCardDimens.heartOpacity),
      weight: _popWeight,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: PostCardDimens.heartOpacity, end: 0),
      weight: _fadeWeight,
    ),
  ]).animate(_controller);

  void play() => _controller.forward(from: 0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, heart) =>
            _controller.isDismissed ? const SizedBox.shrink() : heart!,
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              child: AppSvgIcon(
                AppAssets.heartFilled,
                size: PostCardDimens.heart,
                color: context.appColors.like,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
