import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../shared/content/data/enums/content_audience.dart';
import '../../cubit/new_post_cubit.dart';
import '../../cubit/new_post_state.dart';
import '../../dimens/post_composer_dimens.dart';
import '../../utils/content_audience_display.dart';
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
          const CaptionField(),
          SizedBox(height: AppSpacing.s12),
          const MediaStrip(),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow();

  Future<void> _chooseAudience(BuildContext context) async {
    final cubit = context.read<NewPostCubit>();
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
    final colors = context.appColors;
    final me = context.read<NewPostCubit>().me;
    final name = me?.fullName ?? me?.username;
    return Row(
      children: [
        AvatarInitials(
          name: name,
          seed: me?.id,
          size: PostComposerDimens.avatar,
        ),
        SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (name != null)
                AppText(
                  name,
                  style: context.text.name,
                  color: colors.textPrimary,
                  maxLines: 1,
                ),
              SizedBox(height: AppSpacing.s4),
              BlocSelector<
                NewPostCubit,
                NewPostState,
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
}
