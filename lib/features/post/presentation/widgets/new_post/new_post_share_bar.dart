import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../cubit/new_post_cubit.dart';
import '../../cubit/new_post_state.dart';

/// The "Share post" pill pinned under the scroll area.
class NewPostShareBar extends StatelessWidget {
  const NewPostShareBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewPostCubit>();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        PostComposerDimens.shareSide,
        AppSpacing.s8,
        PostComposerDimens.shareSide,
        PostComposerDimens.shareBottom,
      ),
      child: BlocBuilder<NewPostCubit, NewPostState>(
        buildWhen: (before, now) =>
            before.canShare != now.canShare ||
            before.isSharing != now.isSharing,
        builder: (context, state) => PrimaryButton(
          label: context.l10n.newPostShare,
          expand: true,
          loading: state.isSharing,
          buttonHeight: PostComposerDimens.shareHeight,
          onPressed: state.canShare ? cubit.share : null,
        ),
      ),
    );
  }
}
