import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/media_picker_service.dart';
import '../../cubit/add_edit_post_cubit.dart';
import '../../cubit/add_edit_post_state.dart';
import '../../dimens/post_composer_dimens.dart';
import 'add_media_tile.dart';
import 'media_thumb.dart';

/// The post's own photos and videos when editing, then the ones picked now, then the Add tile until the post
/// is full.
class MediaStrip extends StatelessWidget {
  const MediaStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddEditPostCubit>();
    return BlocBuilder<AddEditPostCubit, AddEditPostState>(
      buildWhen: (before, now) =>
          before.kept != now.kept ||
          before.urls != now.urls ||
          before.media != now.media ||
          before.posters != now.posters,
      builder: (context, state) {
        final count = state.mediaCount;
        return SizedBox(
          height: PostComposerDimens.thumb,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: count + (state.canAddMedia ? 1 : 0),
            separatorBuilder: (_, _) =>
                SizedBox(width: PostComposerDimens.thumbGap),
            itemBuilder: (context, index) {
              if (index == count) return AddMediaTile(onTap: cubit.pickMedia);
              if (index < state.kept.length) {
                final item = state.kept[index];
                final key = item.isVideo ? item.thumbPath : item.path;
                return MediaThumb(
                  key: ValueKey(item.path),
                  index: index,
                  url: state.urls[key],
                  cacheKey: key,
                  durationMs: item.isVideo ? item.durationMs : null,
                  onRemove: () => cubit.removeMedia(index),
                );
              }
              final PickedMedia media = state.media[index - state.kept.length];
              final picture = media.isVideo
                  ? state.posters[media.path]
                  : media.path;
              return MediaThumb(
                key: ValueKey(media.path),
                index: index,
                filePath: picture,
                durationMs: media.isVideo ? media.durationMs : null,
                onRemove: () => cubit.removeMedia(index),
              );
            },
          ),
        );
      },
    );
  }
}
