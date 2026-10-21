import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../domain/entity/post_tag_entity.dart';
import '../dimens/post_card_dimens.dart';
import '../utils/post_card_media.dart';
import '../utils/post_media_aspect.dart';
import '../utils/post_video_ids.dart';
import 'media/post_heart_burst.dart';
import 'media/post_image_item.dart';
import 'media/post_media_chip.dart';
import 'media/post_tag_badge.dart';
import 'media/post_tag_labels.dart';
import 'media/post_video_item.dart';

/// The pictures and videos of a post, shaped by the first item. Several swipe, with dots and a "1/4" counter.
/// A double tap plays the big heart and calls [onDoubleTap].
class PostMedia extends StatefulWidget {
  const PostMedia({
    super.key,
    required this.postId,
    required this.items,
    this.onDoubleTap,
    this.onTap,
    this.tags = const [],
    this.viewerId,
    this.onTaggedPerson,
    this.onTaggedPeople,
    this.onRemoveMyTag,
  });

  final String postId;
  final List<PostCardMedia> items;
  final VoidCallback? onDoubleTap;

  /// Every tap on the media (the framed original of a share opens its post).
  final VoidCallback? onTap;

  /// The people tagged on the post: a person badge shows on each photo, and a tap puts their names at the
  /// spots they were tagged on that photo.
  final List<PostTagEntity> tags;

  /// The signed-in user: their own label can remove their tag.
  final String? viewerId;
  final ValueChanged<String>? onTaggedPerson;
  final VoidCallback? onTaggedPeople;
  final VoidCallback? onRemoveMyTag;

  @override
  State<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia> {
  /// Two taps this close are a double tap. Taps are read here (not with `onDoubleTap`) so a button on the
  /// media, the mute switch or a retry, answers at once instead of waiting to see if a second tap comes.
  static const _doubleTapWindow = Duration(milliseconds: 300);

  final _heart = GlobalKey<PostHeartBurstState>();
  final _page = ValueNotifier<int>(0);
  final _labelsVisible = ValueNotifier<bool>(false);
  Timer? _hideLabels;
  DateTime? _lastTap;

  @override
  void dispose() {
    _hideLabels?.cancel();
    _labelsVisible.dispose();
    _page.dispose();
    super.dispose();
  }

  /// Shows the labels for a few seconds, or hides them. A double tap (a like) leaves them as they were.
  void _toggleLabels() {
    if (widget.tags.isEmpty) return;
    _hideLabels?.cancel();
    final show = !_labelsVisible.value;
    _labelsVisible.value = show;
    if (show) {
      _hideLabels = Timer(
        PostCardDimens.tagLabelsVisible,
        () => _labelsVisible.value = false,
      );
    }
  }

  void _onPageChanged(int page) {
    _page.value = page;
    _hideLabels?.cancel();
    _labelsVisible.value = false;
  }

  void _onTap() {
    widget.onTap?.call();
    final now = clock.now();
    final last = _lastTap;
    if (last != null && now.difference(last) <= _doubleTapWindow) {
      _lastTap = null;
      _toggleLabels();
      _heart.currentState?.play();
      widget.onDoubleTap?.call();
    } else {
      _lastTap = now;
      _toggleLabels();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final hasMany = items.length > 1;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: postMediaAspect(items.first),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PostCardDimens.mediaRadius),
            child: GestureDetector(
              excludeFromSemantics: true,
              onTap: _onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: items.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) => ValueListenableBuilder(
                      valueListenable: _page,
                      builder: (context, page, _) => _Item(
                        id: postVideoId(widget.postId, index),
                        media: items[index],
                        isCurrent: index == page,
                      ),
                    ),
                  ),
                  if (hasMany)
                    PositionedDirectional(
                      top: PostCardDimens.mediaInset,
                      end: PostCardDimens.mediaInset,
                      child: ValueListenableBuilder(
                        valueListenable: _page,
                        builder: (context, page, _) => Semantics(
                          container: true,
                          label: context.l10n.postMediaCounter(
                            page + 1,
                            items.length,
                          ),
                          excludeSemantics: true,
                          child: PostMediaChip(
                            text: '${page + 1}/${items.length}',
                          ),
                        ),
                      ),
                    ),
                  if (widget.tags.isNotEmpty) ...[
                    ValueListenableBuilder(
                      valueListenable: _labelsVisible,
                      builder: (context, visible, _) => visible
                          ? _TagLabelsOfPage(
                              page: _page,
                              tags: widget.tags,
                              viewerId: widget.viewerId,
                              onPerson: widget.onTaggedPerson,
                              onRemoveMe: widget.onRemoveMyTag,
                            )
                          : const SizedBox.shrink(),
                    ),
                    PositionedDirectional(
                      bottom: PostCardDimens.mediaInset,
                      start: PostCardDimens.mediaInset,
                      child: ValueListenableBuilder(
                        valueListenable: _page,
                        builder: (context, page, _) => items[page].isVideo
                            ? const SizedBox.shrink()
                            : PostTagBadge(
                                onTap: _toggleLabels,
                                onLongPress: widget.onTaggedPeople,
                              ),
                      ),
                    ),
                  ],
                  PostHeartBurst(key: _heart),
                ],
              ),
            ),
          ),
        ),
        if (hasMany)
          Padding(
            padding: EdgeInsets.only(top: PostCardDimens.dotsTop),
            child: ValueListenableBuilder(
              valueListenable: _page,
              builder: (context, page, _) =>
                  _Dots(count: items.length, selected: page),
            ),
          ),
      ],
    );
  }
}

/// The labels of the photo on screen: the tags with a spot on it.
class _TagLabelsOfPage extends StatelessWidget {
  const _TagLabelsOfPage({
    required this.page,
    required this.tags,
    this.viewerId,
    this.onPerson,
    this.onRemoveMe,
  });

  final ValueNotifier<int> page;
  final List<PostTagEntity> tags;
  final String? viewerId;
  final ValueChanged<String>? onPerson;
  final VoidCallback? onRemoveMe;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: page,
    builder: (context, index, _) => PostTagLabels(
      tags: [
        for (final tag in tags)
          if (tag.mediaPosition == index && tag.x != null && tag.y != null) tag,
      ],
      viewerId: viewerId,
      onPerson: onPerson,
      onRemoveMe: onRemoveMe,
    ),
  );
}

class _Item extends StatelessWidget {
  const _Item({required this.id, required this.media, required this.isCurrent});

  final String id;
  final PostCardMedia media;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) => media.isVideo
      ? PostVideoItem(id: id, media: media, isCurrent: isCurrent)
      : PostImageItem(media: media);
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.selected});

  final int count;
  final int selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) SizedBox(width: PostCardDimens.dotGap),
            Container(
              width: PostCardDimens.dot,
              height: PostCardDimens.dot,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == selected ? colors.primary : colors.border,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
