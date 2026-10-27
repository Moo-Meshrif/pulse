import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/utils/story_post_args.dart';
import '../../../data/enums/story_post_sticker_style.dart';
import '../../../data/model/story_model.dart';
import '../../../data/model/story_overlay_model.dart';
import '../../../data/model/story_shared_post_model.dart';
import '../../cubit/story_viewer/story_viewer_cubit.dart';
import '../../dimens/story_constants.dart';
import '../../dimens/story_dimens.dart';
import '../../utils/enums/story_pause_reason.dart';
import '../story_overlays_layer.dart';
import 'story_post_sticker.dart';
import 'story_post_unavailable.dart';
import 'story_view_post_pill.dart';

/// The post a story shows, drawn where the author put it (docs/specs/post/screens/s13-add-to-story.md).
/// Tapping it pauses the story, dims the rest and offers "View post"; tapping anywhere else plays on. A
/// post that is gone shows the frosted "Post unavailable" card, which does nothing.
class StoryPostLayer extends StatefulWidget {
  const StoryPostLayer({
    super.key,
    required this.story,
    required this.isActive,
  });

  /// A story with a `sticker`.
  final StoryModel story;

  /// Only the person on screen reacts to taps.
  final bool isActive;

  @override
  State<StoryPostLayer> createState() => _StoryPostLayerState();
}

class _StoryPostLayerState extends State<StoryPostLayer> {
  final _stickerKey = GlobalKey();
  late final StoryViewerCubit _cubit;
  bool _isOpen = false;

  /// Bottom centre of the sticker on screen, where the pill hangs from.
  Offset? _anchor;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<StoryViewerCubit>();
  }

  @override
  void didUpdateWidget(StoryPostLayer old) {
    super.didUpdateWidget(old);
    if (!widget.isActive && _isOpen) _close();
  }

  @override
  void dispose() {
    if (_isOpen) _cubit.resume(StoryPauseReason.post);
    super.dispose();
  }

  void _open() {
    _cubit.pause(StoryPauseReason.post);
    setState(() => _isOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _close() {
    _cubit.resume(StoryPauseReason.post);
    setState(() {
      _isOpen = false;
      _anchor = null;
    });
  }

  void _measure() {
    final sticker = _stickerKey.currentContext?.findRenderObject();
    final layer = context.findRenderObject();
    if (!mounted ||
        sticker is! RenderBox ||
        layer is! RenderBox ||
        !sticker.hasSize) {
      return;
    }
    final rect = MatrixUtils.transformRect(
      sticker.getTransformTo(layer),
      Offset.zero & sticker.size,
    );
    final maxTop = layer.size.height - StoryPostDimens.viewPillHeight * 2;
    setState(
      () => _anchor = Offset(
        rect.center.dx,
        (rect.bottom + StoryPostDimens.viewPillGap).clamp(0, maxTop),
      ),
    );
  }

  Future<void> _viewPost(String postId) async {
    await AppNavigator.push(
      context,
      AppRoutes.postPage(postId),
      rootNavigator: true,
    );
    if (mounted && _isOpen) _close();
  }

  @override
  Widget build(BuildContext context) {
    final sticker = widget.story.sticker;
    final post = widget.story.sharedPost;
    final postId = post?.id;
    final isGone = post == null || postId == null;
    final anchor = _anchor;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              child: ColoredBox(
                color: context.appColors.black.withValues(
                  alpha: StoryOpacity.postDim,
                ),
              ),
            ),
          ),
        StoryOverlayPlacement(
          overlay: StoryOverlayModel(
            x: sticker?.x ?? 0.5,
            y: sticker?.y ?? StoryPostDimens.defaultY,
            scale: isGone ? 1 : sticker?.scale ?? 1,
            rotation: isGone
                ? 0
                : sticker?.rotation ?? StoryPostDimens.defaultTilt,
          ),
          child: isGone
              ? const IgnorePointer(child: StoryPostUnavailable())
              : GestureDetector(
                  key: _stickerKey,
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.isActive && !_isOpen ? _open : null,
                  child: StoryPostSticker(
                    post: _argsOf(post, postId),
                    style: sticker?.style ?? StoryPostStickerStyle.card,
                  ),
                ),
        ),
        if (anchor != null && !isGone)
          Positioned(
            left: anchor.dx,
            top: anchor.dy,
            child: FractionalTranslation(
              translation: const Offset(-0.5, 0),
              child: StoryViewPostPill(onPressed: () => _viewPost(postId)),
            ),
          ),
      ],
    );
  }

  StoryPostArgs _argsOf(StorySharedPostModel post, String postId) {
    final first = post.media?.firstOrNull;
    final width = first?.width;
    final height = first?.height;
    return StoryPostArgs(
      postId: postId,
      username: post.username ?? '',
      avatarUrl: post.avatarUrl,
      caption: post.caption,
      mediaUrl: post.pictureUrl,
      mediaCacheKey: post.pictureKey,
      mediaAspect: width != null && height != null && height > 0
          ? width / height
          : null,
    );
  }
}
