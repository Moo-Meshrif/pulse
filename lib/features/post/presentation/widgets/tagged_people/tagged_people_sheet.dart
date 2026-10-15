import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/extensions/notice_context.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/follow_state.dart';
import '../../../domain/entity/tagged_person_entity.dart';
import '../../cubit/tagged_people_cubit.dart';
import '../../cubit/tagged_people_state.dart';
import '../../dimens/tagged_people_dimens.dart';
import '../../utils/enums/tagged_people_status.dart';
import '../../utils/tagged_people_result.dart';
import 'tagged_person_row.dart';

/// Everyone tagged on a post, with Follow / Following / Requested on each row
/// (docs/specs/post/screens/s10-tagged-people.md). Closes with a [TaggedPeopleResult] when a row opens a
/// profile or your own row asks to remove your tag.
abstract final class TaggedPeopleSheet {
  static Future<TaggedPeopleResult?> show(
    BuildContext context, {
    required String postId,
  }) => AppBottomSheet.show<TaggedPeopleResult>(
    context,
    title: context.l10n.postTaggedPeopleTitle,
    child: BlocProvider(
      create: (_) => getIt<TaggedPeopleCubit>(param1: postId)..load(),
      child: const _Body(),
    ),
  );
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<TaggedPeopleCubit, TaggedPeopleState>(
    listenWhen: (before, now) =>
        now.failure != null && before.failure != now.failure,
    listener: (context, state) => context.showFailure(state.failure),
    child:
        BlocSelector<TaggedPeopleCubit, TaggedPeopleState, TaggedPeopleStatus>(
          selector: (state) => state.status,
          builder: (context, status) => switch (status) {
            TaggedPeopleStatus.loading => SizedBox(
              height: TaggedPeopleDimens.loadingHeight,
              child: const AppLoadingView(),
            ),
            TaggedPeopleStatus.failed => const _LoadFailed(),
            TaggedPeopleStatus.ready => const _People(),
          },
        ),
  );
}

class _People extends StatelessWidget {
  const _People();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TaggedPeopleCubit>();
    return BlocSelector<
      TaggedPeopleCubit,
      TaggedPeopleState,
      List<TaggedPersonEntity>
    >(
      selector: (state) => state.people,
      builder: (context, people) => ListView.separated(
        shrinkWrap: true,
        itemCount: people.length,
        separatorBuilder: (_, _) => SizedBox(height: TaggedPeopleDimens.rowGap),
        itemBuilder: (context, index) {
          final person = people[index];
          return TaggedPersonRow(
            person: person,
            onOpen: () => AppNavigator.back(
              context,
              TaggedPeopleResult.profile(person.id),
            ),
            onPill: () => person.followState == FollowState.me
                ? AppNavigator.back(
                    context,
                    const TaggedPeopleResult.removeMe(),
                  )
                : cubit.toggleFollow(person),
          );
        },
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: TaggedPeopleDimens.loadingHeight,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            context.l10n.postTaggedLoadError,
            style: context.text.bodySm,
            color: context.appColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: context.read<TaggedPeopleCubit>().load,
            child: AppText(
              context.l10n.retry,
              style: context.text.name,
              color: context.appColors.primary,
            ),
          ),
        ],
      ),
    ),
  );
}
