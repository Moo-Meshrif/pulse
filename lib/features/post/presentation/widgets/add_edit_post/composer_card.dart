import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../shared/content/data/enums/content_audience.dart';
import '../../cubit/add_edit_post_cubit.dart';
import '../../cubit/add_edit_post_state.dart';
import '../../dimens/post_composer_dimens.dart';
import '../../utils/content_audience_display.dart';
import '../../utils/post_card_callbacks.dart';
import '../../utils/post_card_data.dart';
import '../post_headline.dart';
import '../post_meta_line.dart';
import '../post_ringed_avatar.dart';
import '../post_visibility/post_visibility_sheet.dart';
import '../post_visibility/visibility_toast.dart';
import 'caption_field.dart';
import 'media_strip.dart';
import 'visibility_chip.dart';

/// The white card at the top: who is posting and for whom, the caption and the media strip.
class ComposerCard extends StatelessWidget {
  const ComposerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: EdgeInsets.all(PostComposerDimens.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(PostComposerDimens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AuthorRow(),
          SizedBox(height: AppSpacing.s12),
          CaptionField(
            initial: context.read<AddEditPostCubit>().state.caption,
            onChanged: context.read<AddEditPostCubit>().captionChanged,
          ),
          SizedBox(height: AppSpacing.s12),
          const MediaStrip(),
        ],
      ),
    );
  }
}

/// What the feed card will say about the post: the name, the feeling, the tagged people, and the place.
class _HeadlinePreview extends StatelessWidget {
  const _HeadlinePreview({required this.name, this.authorId});

  final String name;
  final String? authorId;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AddEditPostCubit, AddEditPostState>(
        buildWhen: (before, now) =>
            before.mood != now.mood ||
            before.tags != now.tags ||
            before.location != now.location,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeadline(
              data: PostCardData(
                id: state.postId,
                authorId: authorId ?? '',
                authorName: name,
                isMine: true,
                createdAt: DateTime.fromMillisecondsSinceEpoch(0),
                mood: state.mood,
                tags: [for (final tag in state.tags) tag.toTag()],
                tagCount: state.tags.length,
              ),
              callbacks: const PostCardCallbacks(),
            ),
            if (state.location != null) PostMetaLine(location: state.location),
          ],
        ),
      );
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow();

  Future<void> _chooseAudience(BuildContext context) async {
    final cubit = context.read<AddEditPostCubit>();
    final result = await PostVisibilitySheet.choose(
      context,
      audience: cubit.state.visibility,
    );
    if (result == null) return;
    cubit.audienceChosen(result);
    final notice = result.firstUseNotice;
    if (notice == null || !context.mounted) return;
    VisibilityToast.show(
      context,
      title: notice.noticeTitle(context)!,
      body: notice.noticeBody(context, reach: result.reach),
      icon: notice.icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = context.read<AddEditPostCubit>().me;
    final name = me?.fullName ?? me?.username;
    return Row(
      children: [
        _buildAutorAvatar(id: me?.id, name: name, url: me?.avatarUrl),
        SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (name != null) _HeadlinePreview(name: name, authorId: me?.id),
              SizedBox(height: AppSpacing.s4),
              BlocSelector<
                AddEditPostCubit,
                AddEditPostState,
                ({ContentAudience audience, bool isNarrowed})
              >(
                selector: (state) => (
                  audience: state.visibility,
                  isNarrowed: state.isVisibilityNarrowed,
                ),
                builder: (context, chip) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: VisibilityChip(
                    audience: chip.audience,
                    isNarrowed: chip.isNarrowed,
                    onTap: () => _chooseAudience(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAutorAvatar({String? id, String? name, String? url}) {
    if (id != null && url != null && name != null) {
      return PostRingedAvatar(authorId: id, name: name, avatarUrl: url);
    }
    return AvatarInitials(
      name: name,
      seed: id,
      size: PostComposerDimens.avatar,
    );
  }
}
