import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/feed/feed_cubit.dart';
import '../../cubit/feed/feed_state.dart';
import '../../dimens/home_dimens.dart';
import '../../utils/feed_floaters_rules.dart';
import '../../utils/feed_post.dart';
import 'back_to_top_button.dart';
import 'new_posts_pill.dart';

enum _Floater { none, pill, backToTop }

/// What floats over the feed (docs/specs/home/screens/s2-new-posts-pill.md): the "New posts" pill when
/// posts wait and the person is more than a screen down, the round back to top button when they are more
/// than three screens down and nothing waits. It also lets new posts in at once while the person is near
/// the top. It reads where the feed is scrolled to from the tab's primary scroll controller and only
/// rebuilds when what floats changes.
class FeedFloaters extends StatefulWidget {
  const FeedFloaters({super.key});

  @override
  State<FeedFloaters> createState() => _FeedFloatersState();
}

class _FeedFloatersState extends State<FeedFloaters> {
  ScrollController? _scroll;
  Timer? _autoHide;
  bool _isExpired = false;
  int _pendingCount = 0;
  final _floater = ValueNotifier(_Floater.none);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = PrimaryScrollController.maybeOf(context);
    if (next == _scroll) return;
    _scroll?.removeListener(_update);
    _scroll = next?..addListener(_update);
  }

  @override
  void dispose() {
    _scroll?.removeListener(_update);
    _autoHide?.cancel();
    _floater.dispose();
    super.dispose();
  }

  /// The feed's scroll position once it has been laid out; null before that (reading it earlier throws).
  ScrollPosition? get _position {
    final scroll = _scroll;
    if (scroll == null || !scroll.hasClients) return null;
    final position = scroll.position;
    return position.hasPixels && position.hasViewportDimension
        ? position
        : null;
  }

  void _update() {
    final position = _position;
    if (position == null) return;
    final offset = position.pixels;
    final viewport = position.viewportDimension;
    if (FeedFloatersRules.showPill(
      offset: offset,
      viewport: viewport,
      pending: _pendingCount,
      isScrollingDown: position.userScrollDirection == ScrollDirection.reverse,
      isExpired: _isExpired,
    )) {
      _floater.value = _Floater.pill;
    } else if (FeedFloatersRules.showBackToTop(
      offset: offset,
      viewport: viewport,
      pending: _pendingCount,
    )) {
      _floater.value = _Floater.backToTop;
    } else {
      _floater.value = _Floater.none;
    }
  }

  bool _isNearTop() {
    final position = _position;
    return position == null ||
        FeedFloatersRules.isNearTop(
          position.pixels,
          position.viewportDimension,
        );
  }

  bool _hasPendingChanged(FeedState before, FeedState state) =>
      before.pendingPosts.length != state.pendingPosts.length;

  void _pendingChanged(BuildContext context, FeedState state) {
    final count = state.pendingPosts.length;
    final isNewBatch = count > _pendingCount;
    _pendingCount = count;
    if (count == 0) {
      _autoHide?.cancel();
    } else if (isNewBatch) {
      _isExpired = false;
      _autoHide?.cancel();
      _autoHide = Timer(HomeDimens.pillAutoHide, () {
        _isExpired = true;
        _update();
      });
      // Near the top nothing the person reads moves much: the posts go in at once.
      if (_isNearTop()) {
        context.read<FeedCubit>().showPending();
        return;
      }
    }
    _update();
  }

  void _showPending() {
    context.read<FeedCubit>().showPending();
    unawaited(_scrollToTop());
  }

  Future<void> _scrollToTop() async {
    final position = _position;
    final scroll = _scroll;
    if (position == null || scroll == null) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      scroll.jumpTo(0);
      return;
    }
    final viewport = position.viewportDimension;
    if (FeedFloatersRules.jumpsFirst(position.pixels, viewport)) {
      scroll.jumpTo(viewport);
    }
    await scroll.animateTo(
      0,
      duration: HomeDimens.scrollToTopDuration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : HomeDimens.pillSlide;
    return BlocListener<FeedCubit, FeedState>(
      listenWhen: _hasPendingChanged,
      listener: _pendingChanged,
      child: ValueListenableBuilder<_Floater>(
        valueListenable: _floater,
        builder: (context, floater, _) => Stack(
          children: [
            PositionedDirectional(
              top: HomeDimens.headerHeight + HomeDimens.pillGapBelowHeader,
              start: 0,
              end: 0,
              child: Center(
                child: AnimatedSwitcher(
                  duration: duration,
                  transitionBuilder: _slideDown,
                  child: floater == _Floater.pill
                      ? BlocSelector<FeedCubit, FeedState, List<FeedPost>>(
                          selector: (state) => state.pendingPosts,
                          builder: (context, pending) => pending.isEmpty
                              ? const SizedBox.shrink()
                              : NewPostsPill(
                                  pending: pending,
                                  onTap: _showPending,
                                ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            PositionedDirectional(
              end: HomeDimens.backToTopEnd,
              bottom: HomeDimens.backToTopAboveNav,
              child: AnimatedSwitcher(
                duration: duration,
                child: floater == _Floater.backToTop
                    ? BackToTopButton(onTap: _scrollToTop)
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slideDown(Widget child, Animation<double> animation) =>
      FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: Offset(0, -HomeDimens.pillSlideFrom / HomeDimens.pillHeight),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
}
