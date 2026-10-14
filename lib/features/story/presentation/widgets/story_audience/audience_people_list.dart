import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/audience_list.dart';
import '../../../data/model/audience_person_model.dart';
import '../../cubit/audience_list_cubit.dart';
import '../../cubit/audience_list_state.dart';
import '../../utils/enums/audience_list_status.dart';
import '../story_menus/story_confirm_dialog.dart';
import 'audience_person_row.dart';

/// The followers of a list screen: loading, failed, empty, or the rows with paging.
class AudiencePeopleList extends StatelessWidget {
  const AudiencePeopleList({super.key});

  /// Ticking someone who is on the other list asks first: it takes them off that list.
  Future<void> _pick(
    BuildContext context,
    AudienceListState state,
    AudiencePersonModel person,
  ) async {
    final cubit = context.read<AudienceListCubit>();
    final needsAsk =
        (person.isInOtherList ?? false) && !state.isSelected(person);
    if (needsAsk && !await _confirmMove(context, cubit.list, person)) return;
    cubit.toggle(person);
  }

  Future<bool> _confirmMove(
    BuildContext context,
    AudienceList list,
    AudiencePersonModel person,
  ) {
    final l10n = context.l10n;
    final name = person.fullName ?? person.username ?? '';
    final isHide = list == AudienceList.hiddenFrom;
    return StoryConfirmDialog.show(
      context,
      icon: isHide ? AppAssets.userMinus : AppAssets.star,
      isDestructive: isHide,
      title: isHide
          ? l10n.storyMoveToHiddenTitle(name)
          : l10n.storyMoveToCloseTitle(name),
      body: isHide
          ? l10n.storyMoveToHiddenBody(name)
          : l10n.storyMoveToCloseBody(name),
      confirmLabel: isHide
          ? l10n.storyMoveToHiddenConfirm
          : l10n.storyMoveToCloseConfirm,
      cancelLabel: l10n.cancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cubit = context.read<AudienceListCubit>();
    final l10n = context.l10n;
    return BlocBuilder<AudienceListCubit, AudienceListState>(
      builder: (context, state) {
        switch (state.status) {
          case AudienceListStatus.loading:
            return Center(
              child: PulseLineLoader(
                color: colors.storyOnDark,
                width: LoadingDimens.loadMoreWidth,
              ),
            );
          case AudienceListStatus.failed:
            return _Message(
              text: l10n.storyAudienceLoadFailed,
              action: l10n.retry,
              onAction: cubit.retry,
            );
          case AudienceListStatus.ready:
            if (state.people.isEmpty) {
              return _Message(text: l10n.storyAudienceEmpty);
            }
            return LoadMoreListener(
              onLoadMore: cubit.loadMore,
              triggerDistance: StoryDimens.viewerRowHeight * 3,
              child: ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: state.people.length + 1,
                itemBuilder: (context, i) => i < state.people.length
                    ? AudiencePersonRow(
                        person: state.people[i],
                        selected: state.isSelected(state.people[i]),
                        onTap: () => _pick(context, state, state.people[i]),
                      )
                    : (state.loadMoreFailed
                          ? _Message(
                              text: l10n.storyAudienceLoadFailed,
                              action: l10n.retry,
                              onAction: cubit.loadMore,
                            )
                          : SizedBox(height: AppSpacing.s16)),
              ),
            );
        }
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text,
            style: context.text.bodySm,
            color: colors.storyOnDark.withValues(alpha: StoryOpacity.subtitle),
            textAlign: TextAlign.center,
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              child: AppText(
                action!,
                style: context.text.name,
                color: colors.storyOnDark,
              ),
            ),
        ],
      ),
    );
  }
}
