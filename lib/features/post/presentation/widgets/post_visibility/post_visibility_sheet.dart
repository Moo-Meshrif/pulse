import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/failure_l10n.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../shared/content/data/enums/content_audience.dart';
import '../../cubit/post_visibility_cubit.dart';
import '../../cubit/post_visibility_state.dart';
import '../../utils/content_audience_display.dart';
import '../../utils/enums/post_visibility_status.dart';
import '../../utils/post_visibility_result.dart';
import 'visibility_future_toggle.dart';
import 'visibility_option_row.dart';
import 'visibility_private_note.dart';
import 'visibility_toast.dart';

/// Who can see a post (docs/specs/post/screens/s4-visibility.md): four audiences and one button. From New
/// post it hands back the choice; from an existing post it saves the change.
abstract final class PostVisibilitySheet {
  /// New post: the choice when the person pressed Done, or null when the sheet was dismissed.
  static Future<PostVisibilityResult?> choose(
    BuildContext context, {
    required ContentAudience audience,
  }) => _show(
    context,
    title: context.l10n.postVisibilityTitle,
    postId: null,
    audience: audience,
  );

  /// An existing post: the audience it has after Save, or null when nothing changed.
  static Future<ContentAudience?> change(
    BuildContext context, {
    required String postId,
    required ContentAudience audience,
  }) async {
    final result = await _show(
      context,
      title: context.l10n.postVisibilityChangeTitle,
      postId: postId,
      audience: audience,
    );
    return result == null || result.audience == audience
        ? null
        : result.audience;
  }

  static Future<PostVisibilityResult?> _show(
    BuildContext context, {
    required String title,
    required String? postId,
    required ContentAudience audience,
  }) => AppBottomSheet.show<PostVisibilityResult>(
    context,
    title: title,
    child: BlocProvider(
      create: (_) =>
          getIt<PostVisibilityCubit>(param1: postId, param2: audience)
            ..loadChoices(),
      child: BlocListener<PostVisibilityCubit, PostVisibilityState>(
        listenWhen: (before, now) =>
            before.result == null && now.result != null,
        listener: _closeWithResult,
        child: const _Body(),
      ),
    ),
  );

  static void _closeWithResult(
    BuildContext context,
    PostVisibilityState state,
  ) => AppNavigator.back(context, state.result);
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostVisibilityCubit>();
    return BlocSelector<
      PostVisibilityCubit,
      PostVisibilityState,
      PostVisibilityStatus
    >(
      selector: (state) => state.status,
      builder: (context, status) => switch (status) {
        PostVisibilityStatus.loading => SizedBox(
          height: VisibilityDimens.loadingHeight,
          child: const AppLoadingView(),
        ),
        PostVisibilityStatus.failed => _LoadFailed(onRetry: cubit.loadChoices),
        PostVisibilityStatus.ready => const _Ready(),
      },
    );
  }
}

class _Ready extends StatelessWidget {
  const _Ready();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostVisibilityCubit>();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s12,
        children: [
          if (!cubit.isNewPost) const _Currently(),
          const _PrivateNote(),
          const _Choices(),
          if (cubit.isNewPost) const _FutureToggle() else const _KeptNote(),
          const _FailureLine(),
          const _ActionButton(),
        ],
      ),
    );
  }
}

class _Currently extends StatelessWidget {
  const _Currently();

  @override
  Widget build(BuildContext context) {
    final current = context.read<PostVisibilityCubit>().state.current;
    return AppText(
      context.l10n.postVisibilityCurrently(current.label(context)),
      style: context.text.bodySm,
      color: context.appColors.textSecondary,
    );
  }
}

class _PrivateNote extends StatelessWidget {
  const _PrivateNote();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<PostVisibilityCubit, PostVisibilityState, bool>(
        selector: (state) => state.isPrivate,
        builder: (context, isPrivate) => isPrivate
            ? VisibilityPrivateNote(
                // TODO(post-plan T11): Settings > Privacy is not specced yet. The toast shows above the
                // sheet, where a snackbar would be hidden.
                onPrivacySettings: () => VisibilityToast.show(
                  context,
                  title: context.l10n.comingSoon,
                ),
              )
            : const SizedBox.shrink(),
      );
}

class _Choices extends StatelessWidget {
  const _Choices();

  Future<void> _editCloseFriends(BuildContext context) async {
    final cubit = context.read<PostVisibilityCubit>();
    // `Object?`: the router builds its routes without a result type, so a typed push cannot cast to them.
    final changed = await AppNavigator.push<Object?>(
      context,
      AppRoutes.audienceCloseFriends,
      rootNavigator: true,
    );
    if (changed == true) await cubit.reloadCounts();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final cubit = context.read<PostVisibilityCubit>();
    return BlocBuilder<PostVisibilityCubit, PostVisibilityState>(
      buildWhen: (before, now) =>
          before.audience != now.audience ||
          before.isPrivate != now.isPrivate ||
          before.summary != now.summary,
      builder: (context, state) {
        final summary = state.summary;
        final noCloseFriends = summary.closeFriends == 0;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(VisibilityDimens.groupRadius),
          ),
          child: Column(
            children: [
              VisibilityOptionRow(
                icon: ContentAudience.public.icon,
                title: l10n.postAudiencePublic,
                subtitle: state.isPrivate
                    ? l10n.postVisibilityPublicOff
                    : l10n.postVisibilityPublicHint,
                enabled: !state.isPrivate,
                selected: state.audience == ContentAudience.public,
                onTap: () => cubit.select(ContentAudience.public),
              ),
              VisibilityOptionRow(
                icon: ContentAudience.followers.icon,
                title: l10n.postAudienceFollowers,
                subtitle: l10n.postVisibilityPeople(summary.followers),
                selected: state.audience == ContentAudience.followers,
                onTap: () => cubit.select(ContentAudience.followers),
              ),
              VisibilityOptionRow(
                icon: ContentAudience.closeFriends.icon,
                title: l10n.postAudienceCloseFriends,
                subtitle: l10n.postVisibilityPeople(summary.closeFriends),
                selected: state.audience == ContentAudience.closeFriends,
                // With nobody on the list there is nothing to choose: the row opens the list.
                onTap: noCloseFriends
                    ? () => _editCloseFriends(context)
                    : () => cubit.select(ContentAudience.closeFriends),
                onEdit: () => _editCloseFriends(context),
              ),
              VisibilityOptionRow(
                icon: ContentAudience.onlyMe.icon,
                title: l10n.postAudienceOnlyMe,
                subtitle: l10n.postVisibilityOnlyMeHint,
                selected: state.audience == ContentAudience.onlyMe,
                onTap: () => cubit.select(ContentAudience.onlyMe),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FutureToggle extends StatelessWidget {
  const _FutureToggle();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostVisibilityCubit>();
    return BlocSelector<PostVisibilityCubit, PostVisibilityState, bool>(
      selector: (state) => state.saveAsDefault,
      builder: (context, saveAsDefault) => VisibilityFutureToggle(
        value: saveAsDefault,
        onChanged: cubit.saveAsDefaultChanged,
      ),
    );
  }
}

class _KeptNote extends StatelessWidget {
  const _KeptNote();

  @override
  Widget build(BuildContext context) => AppText(
    context.l10n.postVisibilityKeptNote,
    style: context.text.caption,
    color: context.appColors.textSecondary,
  );
}

class _FailureLine extends StatelessWidget {
  const _FailureLine();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<PostVisibilityCubit, PostVisibilityState, Failure?>(
        selector: (state) => state.failure,
        builder: (context, failure) => failure == null
            ? const SizedBox.shrink()
            : Semantics(
                liveRegion: true,
                child: AppText(
                  failure.l10n(context),
                  style: context.text.bodySm,
                  color: context.appColors.danger,
                ),
              ),
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostVisibilityCubit>();
    final l10n = context.l10n;
    return BlocSelector<PostVisibilityCubit, PostVisibilityState, bool>(
      selector: (state) => state.isSaving,
      builder: (context, isSaving) => PrimaryButton(
        label: cubit.isNewPost
            ? l10n.postVisibilityDone
            : l10n.postVisibilitySave,
        expand: true,
        loading: isSaving,
        buttonHeight: VisibilityDimens.actionHeight,
        onPressed: cubit.confirm,
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: VisibilityDimens.loadingHeight,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            context.l10n.errorGeneric,
            style: context.text.bodySm,
            color: context.appColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: onRetry,
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
