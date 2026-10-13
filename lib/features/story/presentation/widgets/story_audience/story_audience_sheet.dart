import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/enums/sheet_tone.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/failure_l10n.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/story_audience.dart';
import '../../cubit/story_audience_cubit.dart';
import '../../cubit/story_audience_state.dart';
import '../../utils/enums/story_audience_status.dart';
import '../story_white_pill.dart';
import 'audience_group.dart';
import 'audience_sheet_states.dart';
import 'audience_row.dart';

/// Who can see this (docs/specs/story/screenshots/stories-board-v3.png, panel 11): Followers, Close friends
/// (with Edit) and Hide story from, on the dark story sheet. A choice is saved at once; Done only closes.
abstract final class StoryAudienceSheet {
  /// The audience of the story when the sheet closed (whatever way it closed).
  static Future<StoryAudience> show(
    BuildContext context, {
    required String storyId,
    required StoryAudience audience,
  }) async {
    var current = audience;
    await AppBottomSheet.show<void>(
      context,
      tone: SheetTone.dark,
      child: BlocProvider(
        create: (_) =>
            getIt<StoryAudienceCubit>(param1: storyId, param2: audience)
              ..load(),
        child: BlocListener<StoryAudienceCubit, StoryAudienceState>(
          listenWhen: (before, now) => before.audience != now.audience,
          listener: (_, state) => current = state.audience,
          child: const _Body(),
        ),
      ),
    );
    return current;
  }
}

class _Body extends StatelessWidget {
  const _Body();

  Future<void> _openList(BuildContext context, String route) async {
    final cubit = context.read<StoryAudienceCubit>();
    // `Object?`: the router builds its routes without a result type, so a typed push cannot cast to them.
    final changed = await AppNavigator.push<Object?>(
      context,
      route,
      rootNavigator: true,
    );
    if (changed != true) return;
    await cubit.listEdited(
      isCloseFriends: route == AppRoutes.audienceCloseFriends,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final cubit = context.read<StoryAudienceCubit>();
    return BlocBuilder<StoryAudienceCubit, StoryAudienceState>(
      builder: (context, state) {
        // The sheet is drawn once its numbers are known: no rows with blanks that fill in later.
        switch (state.status) {
          case StoryAudienceStatus.loading:
            return const AudienceSheetLoading();
          case StoryAudienceStatus.failed:
            return AudienceSheetLoadFailed(onRetry: cubit.load);
          case StoryAudienceStatus.ready:
            break;
        }
        final noCloseFriends = state.summary.closeFriends == 0;
        String? people(int? count) =>
            count == null ? null : l10n.storyAudiencePeople(count);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: StorySheetDimens.gap,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: StorySheetDimens.titlePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.s8,
                children: [
                  Semantics(
                    header: true,
                    child: AppText(
                      l10n.storyWhoCanSee,
                      style: context.text.stat,
                      color: colors.storyOnDark,
                    ),
                  ),
                  AppText(
                    l10n.storyAudienceBody,
                    style: context.text.bodySm,
                    color: colors.storyOnDark.withValues(
                      alpha: StoryOpacity.helper,
                    ),
                  ),
                ],
              ),
            ),
            AudienceGroup(
              children: [
                AudienceRow(
                  icon: AppAssets.audience,
                  title: l10n.storyAudienceFollowers,
                  subtitle: people(state.summary.followers),
                  selected: state.audience == StoryAudience.followers,
                  onTap: () => cubit.select(StoryAudience.followers),
                ),
                AudienceRow(
                  icon: AppAssets.star,
                  tileColor: colors.storySuccess,
                  tileIconColor: colors.textPrimary,
                  title: l10n.storyAudienceCloseFriends,
                  subtitle: people(state.summary.closeFriends),
                  // With nobody on the list there is nothing to choose: the row opens the list, with
                  // a chevron like Hide story from, and the choice and Edit come once it has people.
                  selected: noCloseFriends
                      ? null
                      : state.audience == StoryAudience.closeFriends,
                  onTap: noCloseFriends
                      ? () => _openList(context, AppRoutes.audienceCloseFriends)
                      : () => cubit.select(StoryAudience.closeFriends),
                  onEdit: noCloseFriends
                      ? null
                      : () =>
                            _openList(context, AppRoutes.audienceCloseFriends),
                ),
              ],
            ),
            AudienceGroup(
              children: [
                AudienceRow(
                  icon: AppAssets.userMinus,
                  title: l10n.storyAudienceHideFrom,
                  subtitle: people(state.summary.hidden),
                  onTap: () => _openList(context, AppRoutes.audienceHidden),
                ),
              ],
            ),
            if (state.failure != null)
              Semantics(
                liveRegion: true,
                child: AppText(
                  state.failure!.l10n(context),
                  style: context.text.bodySm,
                  color: colors.dangerOnDark,
                ),
              ),
            SizedBox(height: AppSpacing.s12),
            StoryWhitePill(
              label: l10n.storyAudienceDone,
              onPressed: () => AppNavigator.back(context),
            ),
          ],
        );
      },
    );
  }
}
