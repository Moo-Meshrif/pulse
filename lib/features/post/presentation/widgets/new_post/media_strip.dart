import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/media_picker_service.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../cubit/new_post_cubit.dart';
import '../../cubit/new_post_state.dart';
import '../../utils/new_post_limits.dart';
import 'add_media_tile.dart';
import 'media_thumb.dart';

/// The photos and videos picked so far, then the Add tile until the post is full.
class MediaStrip extends StatelessWidget {
  const MediaStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewPostCubit>();
    return BlocBuilder<NewPostCubit, NewPostState>(
      buildWhen: (before, now) =>
          before.media != now.media || before.posters != now.posters,
      builder: (context, state) {
        final hasAddTile = state.media.length < NewPostLimits.maxMedia;
        return SizedBox(
          height: PostComposerDimens.thumb,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.media.length + (hasAddTile ? 1 : 0),
            separatorBuilder: (_, _) =>
                SizedBox(width: PostComposerDimens.thumbGap),
            itemBuilder: (context, index) {
              if (index == state.media.length) {
                return AddMediaTile(onTap: cubit.pickMedia);
              }
              final PickedMedia media = state.media[index];
              return MediaThumb(
                key: ValueKey(media.path),
                media: media,
                index: index,
                poster: state.posters[media.path],
                onRemove: () => cubit.removeMedia(index),
              );
            },
          ),
        );
      },
    );
  }
}
