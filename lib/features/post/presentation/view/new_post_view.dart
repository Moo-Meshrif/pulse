import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/new_post_cubit.dart';
import '../cubit/new_post_state.dart';
import '../dimens/post_composer_dimens.dart';
import '../widgets/new_post/composer_card.dart';
import '../widgets/new_post/new_post_options_card.dart';
import '../widgets/new_post/new_post_share_bar.dart';
import '../widgets/new_post/new_post_title_row.dart';

/// The New post layout (docs/specs/post/screens/s1-new-post.md): title row, the composer and options
/// cards in a scroll area, and the Share pill pinned under it. Nothing answers taps while it uploads.
class NewPostView extends StatelessWidget {
  const NewPostView({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPage(
      showTopBar: false,
      backgroundColor: colors.background,
      bottomSpace: PostComposerDimens.shareBottom,
      child: BlocSelector<NewPostCubit, NewPostState, bool>(
        selector: (state) => state.isSharing,
        builder: (context, isSharing) => IgnorePointer(
          ignoring: isSharing,
          child: Column(
            children: [
              NewPostTitleRow(onClose: onClose),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.cardMargin,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ComposerCard(),
                      const _SectionLabel(),
                      const NewPostOptionsCard(),
                    ],
                  ),
                ),
              ),
              const NewPostShareBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel();

  @override
  Widget build(BuildContext context) => Padding(
    padding: PostComposerDimens.sectionLabelMargin,
    child: AppText(
      context.l10n.newPostAddToPost.toUpperCase(),
      style: context.text.section,
      color: context.appColors.textSecondary,
    ),
  );
}
