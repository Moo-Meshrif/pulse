import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/enums/audience_list.dart';
import '../cubit/audience_list/audience_list_cubit.dart';
import '../cubit/audience_list/audience_list_state.dart';
import '../widgets/story_audience/audience_list_header.dart';
import '../widgets/story_audience/audience_list_tabs.dart';
import '../widgets/story_audience/audience_people_list.dart';
import '../widgets/story_audience/audience_search_field.dart';
import '../widgets/story_white_pill.dart';

/// The body of a list screen: header with the count, search, the hint, the two tabs, the followers and
/// Done.
class AudienceListView extends StatelessWidget {
  const AudienceListView({super.key, required this.list});

  final AudienceList list;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AudienceListCubit>();
    final isClose = list == AudienceList.closeFriends;
    return AppSafeArea(
      bottomSpace: OptionSheetDimens.gap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AudienceListHeader(
            title: isClose
                ? l10n.storyCloseFriendsTitle
                : l10n.storyHiddenTitle,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: OptionSheetDimens.gap,
              children: [
                AudienceSearchField(onChanged: cubit.setQuery),
                AppText(
                  isClose ? l10n.storyCloseFriendsHint : l10n.storyHiddenHint,
                  style: context.text.caption,
                  color: context.appColors.onDark.withValues(
                    alpha: DarkOpacity.subtitle,
                  ),
                ),
                const AudienceListTabs(),
              ],
            ),
          ),
          SizedBox(height: OptionSheetDimens.gap),
          const Expanded(child: AudiencePeopleList()),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s16,
              OptionSheetDimens.gap,
              AppSpacing.s16,
              0,
            ),
            // Done is for saving: dimmed until something was ticked or unticked.
            child: BlocBuilder<AudienceListCubit, AudienceListState>(
              buildWhen: (before, now) =>
                  before.isSaving != now.isSaving ||
                  before.hasChanges != now.hasChanges,
              builder: (context, state) => StoryWhitePill(
                label: l10n.storyAudienceDone,
                isLoading: state.isSaving,
                onPressed: state.hasChanges ? cubit.save : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
