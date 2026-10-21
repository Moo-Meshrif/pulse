import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../post/presentation/dimens/post_card_dimens.dart';
import '../../cubit/feed/feed_cubit.dart';
import '../../cubit/feed/feed_state.dart';
import '../../dimens/home_dimens.dart';

/// A soft ring around a post that just arrived on top: it stays a moment, then fades out.
class FreshRing extends StatelessWidget {
  const FreshRing({super.key, required this.postId, required this.child});

  final String postId;
  final Widget child;

  bool _isFresh(FeedState state) => state.freshIds.contains(postId);

  @override
  Widget build(BuildContext context) =>
      BlocSelector<FeedCubit, FeedState, bool>(
        selector: _isFresh,
        builder: (context, isFresh) => _Ring(isFresh: isFresh, child: child),
      );
}

class _Ring extends StatefulWidget {
  const _Ring({required this.isFresh, required this.child});

  final bool isFresh;
  final Widget child;

  @override
  State<_Ring> createState() => _RingState();
}

class _RingState extends State<_Ring> {
  Timer? _stay;
  bool _isShown = false;

  @override
  void initState() {
    super.initState();
    if (widget.isFresh) _show();
  }

  @override
  void didUpdateWidget(_Ring old) {
    super.didUpdateWidget(old);
    if (widget.isFresh && !old.isFresh) _show();
  }

  void _show() {
    _isShown = true;
    _stay?.cancel();
    _stay = Timer(HomeDimens.freshRingStay, () {
      if (mounted) setState(() => _isShown = false);
    });
  }

  @override
  void dispose() {
    _stay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedOpacity(
            opacity: _isShown ? 1 : 0,
            duration: HomeDimens.freshRingFade,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PostCardDimens.radius),
                border: Border.all(
                  color: context.appColors.newPostRing,
                  width: HomeDimens.freshRing,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
