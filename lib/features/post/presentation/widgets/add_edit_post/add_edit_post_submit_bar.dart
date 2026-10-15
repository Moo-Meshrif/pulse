import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../cubit/add_edit_post_cubit.dart';
import '../../cubit/add_edit_post_state.dart';
import '../../dimens/post_composer_dimens.dart';

/// The "Share post" pill ("Save" when editing) pinned under the scroll area.
class AddEditPostSubmitBar extends StatelessWidget {
  const AddEditPostSubmitBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddEditPostCubit>();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        PostComposerDimens.shareSide,
        AppSpacing.s8,
        PostComposerDimens.shareSide,
        PostComposerDimens.shareBottom,
      ),
      child: BlocBuilder<AddEditPostCubit, AddEditPostState>(
        buildWhen: (before, now) =>
            before.isEditing != now.isEditing ||
            before.canSave != now.canSave ||
            before.isSaving != now.isSaving,
        builder: (context, state) => PrimaryButton(
          label: state.isEditing
              ? context.l10n.editPostSave
              : context.l10n.newPostShare,
          expand: true,
          loading: state.isSaving,
          buttonHeight: PostComposerDimens.shareHeight,
          onPressed: state.canSave ? cubit.save : null,
        ),
      ),
    );
  }
}
