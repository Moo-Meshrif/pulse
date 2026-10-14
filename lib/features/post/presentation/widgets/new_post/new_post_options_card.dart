import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/extensions/snack_bar_context.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../shared/places/presentation/utils/location_choice.dart';
import '../../cubit/new_post_cubit.dart';
import '../../cubit/new_post_state.dart';
import 'new_post_option_row.dart';

/// The "Add to your post" card: photo / video, tag people, location, feeling and the comments switch.
class NewPostOptionsCard extends StatelessWidget {
  const NewPostOptionsCard({super.key});

  NewPostCubit _cubit(BuildContext context) => context.read<NewPostCubit>();

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
            BlocSelector<NewPostCubit, NewPostState, int>(
              selector: (state) => state.media.length,
              builder: (context, count) => NewPostOptionRow(
                icon: AppAssets.image,
                title: l10n.newPostPhotoVideo,
                value: count == 0 ? null : l10n.newPostAdded(count),
                onTap: cubit.pickMedia,
              ),
            ),
            // TODO(post-plan T2): Tag people is coming soon.
            NewPostOptionRow(
              icon: AppAssets.tagPerson,
              title: l10n.newPostTag,
              onTap: () => context.showSnackBar(l10n.comingSoon),
            ),
            BlocSelector<NewPostCubit, NewPostState, String?>(
              selector: (state) => state.location,
              builder: (context, location) => NewPostOptionRow(
                icon: AppAssets.location,
                title: l10n.newPostLocation,
                value: location,
                onTap: () => _chooseLocation(context),
              ),
            ),
            // TODO(post-plan T3): Feeling / activity is coming soon.
            NewPostOptionRow(
              icon: AppAssets.smile,
              title: l10n.newPostFeeling,
              onTap: () => context.showSnackBar(l10n.comingSoon),
            ),
            BlocSelector<NewPostCubit, NewPostState, bool>(
              selector: (state) => state.commentsEnabled,
              builder: (context, enabled) => NewPostOptionRow(
                icon: AppAssets.comment,
                title: l10n.newPostAllowComments,
                onTap: () => cubit.commentsChanged(!enabled),
                trailing: Switch(
                  value: enabled,
                  onChanged: cubit.commentsChanged,
                  activeTrackColor: colors.primary,
                  activeThumbColor: colors.surface,
                  inactiveTrackColor: colors.switchOff,
                  inactiveThumbColor: colors.surface,
                  trackOutlineColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
