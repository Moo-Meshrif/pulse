import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/notice/notices.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/utils/location_choice.dart';
import '../../cubit/add_edit_post_cubit.dart';
import '../../cubit/add_edit_post_state.dart';
import '../../dimens/post_composer_dimens.dart';
import 'add_edit_post_option_row.dart';

/// The "Add to your post" card: photo / video, tag people, location, feeling and the comments switch.
class AddEditPostOptionsCard extends StatelessWidget {
  const AddEditPostOptionsCard({super.key});

  AddEditPostCubit _cubit(BuildContext context) =>
      context.read<AddEditPostCubit>();

  Future<void> _chooseLocation(BuildContext context) async {
    final cubit = _cubit(context);
    // `Object?`: the router builds its routes without a result type, so a typed push cannot cast to them.
    final choice = await AppNavigator.push<Object?>(
      context,
      AppRoutes.pickPlace,
      arguments: cubit.state.location,
    );
    if (choice is LocationChoice) cubit.locationChanged(choice.name);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final cubit = _cubit(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(PostComposerDimens.cardRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PostComposerDimens.cardRadius),
        child: Column(
          children: [
            BlocSelector<AddEditPostCubit, AddEditPostState, int>(
              selector: (state) => state.mediaCount,
              builder: (context, count) => AddEditPostOptionRow(
                icon: AppAssets.image,
                title: l10n.newPostPhotoVideo,
                value: count == 0 ? null : l10n.newPostAdded(count),
                onTap: cubit.pickMedia,
              ),
            ),
            // TODO(post-plan T2): Tag people is coming soon.
            AddEditPostOptionRow(
              icon: AppAssets.tagPerson,
              title: l10n.newPostTag,
              onTap: () => Notices.info(l10n.comingSoon),
            ),
            BlocSelector<AddEditPostCubit, AddEditPostState, String?>(
              selector: (state) => state.location,
              builder: (context, location) => AddEditPostOptionRow(
                icon: AppAssets.location,
                title: l10n.newPostLocation,
                value: location,
                onTap: () => _chooseLocation(context),
              ),
            ),
            // TODO(post-plan T3): Feeling / activity is coming soon.
            AddEditPostOptionRow(
              icon: AppAssets.smile,
              title: l10n.newPostFeeling,
              onTap: () => Notices.info(l10n.comingSoon),
            ),
            BlocSelector<AddEditPostCubit, AddEditPostState, bool>(
              selector: (state) => state.commentsEnabled,
              builder: (context, enabled) => AddEditPostOptionRow(
                padding: PostComposerDimens.optionRowPadding.copyWith(top: 0),
                icon: AppAssets.comment,
                title: l10n.newPostAllowComments,
                onTap: () => cubit.commentsChanged(!enabled),
                trailing: Switch(
                  value: enabled,
                  onChanged: cubit.commentsChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
