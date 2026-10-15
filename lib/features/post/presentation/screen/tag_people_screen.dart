import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/tag_people_cubit.dart';
import '../cubit/tag_people_state.dart';
import '../utils/enums/tag_people_status.dart';
import '../utils/new_post_limits.dart';
import '../utils/tag_choice.dart';
import '../utils/tag_people_args.dart';
import '../view/tag_people_view.dart';

/// `/create/post/tag-people`: choose who is tagged in the post (docs/specs/post/screens/s6-tag-people.md).
/// Done goes back with the chosen `List<TagChoice>` (empty clears the tags); the back arrow asks first when
/// something changed.
class TagPeopleScreen extends StatelessWidget {
  const TagPeopleScreen({super.key, required this.args});

  final TagPeopleArgs args;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<TagPeopleCubit>(param1: args)..load(),
    child: Builder(
      builder: (context) => MultiBlocListener(
        listeners: [
          BlocListener<TagPeopleCubit, TagPeopleState>(
            listenWhen: (before, now) => !before.isOverLimit && now.isOverLimit,
            listener: _tellLimit,
          ),
          BlocListener<TagPeopleCubit, TagPeopleState>(
            listenWhen: (before, now) =>
                before.status != TagPeopleStatus.failed &&
                now.status == TagPeopleStatus.failed,
            listener: _tellFailure,
          ),
        ],
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _closeAskingFirst(context);
          },
          child: TagPeopleView(
            hasPhotos: args.hasPhotos,
            onBack: () => _closeAskingFirst(context),
            onDone: () => AppNavigator.back(
              context,
              context.read<TagPeopleCubit>().state.chosen,
            ),
            onTagInPhoto: () => _tagInPhoto(context),
          ),
        ),
      ),
    ),
  );

  void _tellLimit(BuildContext context, TagPeopleState state) {
    Notices.info(context.l10n.postTagPeopleMax(TagLimits.maxPeople));
    context.read<TagPeopleCubit>().clearOverLimit();
  }

  void _tellFailure(BuildContext context, TagPeopleState state) {
    final cubit = context.read<TagPeopleCubit>();
    Notices.error(
      context.l10n.postTagPeopleError,
      actionLabel: context.l10n.retry,
      onResult: (acted) {
        if (acted) cubit.load();
      },
    );
  }

  Future<void> _tagInPhoto(BuildContext context) async {
    final cubit = context.read<TagPeopleCubit>();
    // `Object?`: the router builds its routes without a result type, so a typed push cannot cast to them.
    final result = await AppNavigator.push<Object?>(
      context,
      AppRoutes.tagInPhoto,
      rootNavigator: true,
      arguments: TagPeopleArgs(chosen: cubit.state.chosen, photos: args.photos),
    );
    if (result is List<TagChoice>) cubit.spotsChanged(result);
  }

  Future<void> _closeAskingFirst(BuildContext context) async {
    if (!context.read<TagPeopleCubit>().hasChanges) {
      AppNavigator.back(context);
      return;
    }
    final l10n = context.l10n;
    final discard = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.trash,
      title: l10n.editPostDiscardTitle,
      message: l10n.editPostDiscardBody,
      confirmLabel: l10n.newPostDiscard,
      cancelLabel: l10n.newPostKeepEditing,
    );
    if (discard == true && context.mounted) AppNavigator.back(context);
  }
}
