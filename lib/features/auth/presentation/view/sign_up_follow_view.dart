import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../follow/data/enums/follow_status.dart';
import '../cubit/sign_up_cubit.dart';
import '../cubit/sign_up_state.dart';
import '../utils/enums/follow_tab.dart';
import '../utils/enums/load_status.dart';
import '../widgets/auth_header.dart';
import '../widgets/follow_row.dart';
import '../widgets/skeleton_pill.dart';

/// Sign-up step 6, Follow (docs/specs/auth/screens/s8-signup-follow.md): tabs, the people in one white
/// card, and Continue pinned under a hairline.
class SignUpFollowView extends StatelessWidget {
  const SignUpFollowView({super.key});

  static const _skeletonRows = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final cubit = context.read<SignUpCubit>();
    return PinnedBottomCta(
      showTopDivider: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: AuthDimens.signUpTopGap,
          bottom: AppSpacing.s24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.formSide),
              child: AuthHeader(
                title: l10n.followTitle,
                subtitle: l10n.followSubtitle,
              ),
            ),
            SizedBox(height: AuthDimens.followSectionGap),
            BlocSelector<SignUpCubit, SignUpState, FollowTab>(
              selector: (state) => state.followTab,
              builder: (context, selected) => _tabs(context, selected),
            ),
            BlocBuilder<SignUpCubit, SignUpState>(
              buildWhen: _listHeadingChanged,
              builder: (context, state) => _listHeading(context, state),
            ),
            SizedBox(height: AppSpacing.s8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: BlocBuilder<SignUpCubit, SignUpState>(
                  buildWhen: _peopleCardChanged,
                  builder: (context, state) => _card(context, state),
                ),
              ),
            ),
          ],
        ),
      ),
      cta: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocSelector<SignUpCubit, SignUpState, bool>(
            selector: (state) => state.loading,
            builder: (context, loading) => PrimaryButton(
              label: l10n.continueButton,
              expand: true,
              loading: loading,
              onPressed: loading ? null : cubit.finishFollow,
            ),
          ),
          SizedBox(height: AppSpacing.s8),
          AppText(
            l10n.followHint,
            style: context.text.caption,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _listHeadingChanged(SignUpState before, SignUpState state) =>
      before.followTab != state.followTab ||
      _canFollowAll(before) != _canFollowAll(state);

  bool _peopleCardChanged(SignUpState before, SignUpState state) =>
      before.followTab != state.followTab ||
      before.followStatus != state.followStatus ||
      before.visiblePeople != state.visiblePeople ||
      before.follows != state.follows;

  bool _canFollowAll(SignUpState state) =>
      state.followStatus == LoadStatus.loaded && state.visiblePeople.isNotEmpty;

  Widget _tabs(BuildContext context, FollowTab selected) {
    final cubit = context.read<SignUpCubit>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.formSide),
      child: Row(
        spacing: AuthDimens.chipWrapSpacing,
        children: [
          for (final tab in FollowTab.values)
            SelectableChip(
              label: tab.l10n(context),
              selected: selected == tab,
              dark: true,
              height: AuthDimens.followTabHeight,
              onTap: () => cubit.tabSelected(tab),
            ),
        ],
      ),
    );
  }

  /// "SUGGESTED FOR YOU" with "Follow all"; absent on the tab with no list (Contacts).
  Widget _listHeading(BuildContext context, SignUpState state) {
    if (state.followTab.source == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.formSide,
        AuthDimens.followSectionGap,
        AppSpacing.formSide,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              state.followTab == FollowTab.suggested
                  ? l10n.suggestedForYou
                  : state.followTab.l10n(context).toUpperCase(),
              style: context.text.section,
              color: colors.textSecondary,
            ),
          ),
          if (_canFollowAll(state))
            TextButton(
              onPressed: context.read<SignUpCubit>().followAll,
              style: TextButton.styleFrom(
                minimumSize: const Size(
                  AuthDimens.tapTarget,
                  AuthDimens.tapTarget,
                ),
                foregroundColor: colors.primary,
              ),
              child: AppText(
                l10n.followAll,
                style: context.text.action,
                color: colors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, SignUpState state) {
    final l10n = context.l10n;
    final cubit = context.read<SignUpCubit>();
    if (state.followTab == FollowTab.contacts) {
      return _Message(text: l10n.comingSoon);
    }
    return switch (state.followStatus) {
      LoadStatus.failed => _Message(
        text: l10n.followError,
        onRetry: cubit.retryPeople,
      ),
      LoadStatus.loaded when state.visiblePeople.isEmpty => _Message(
        text: l10n.noSuggestions,
      ),
      LoadStatus.loaded => Column(
        children: [
          for (final person in state.visiblePeople)
            FollowRow(
              key: ValueKey(person.id),
              person: person,
              status: state.follows[person.id] ?? FollowStatus.none,
              onToggle: () => cubit.followToggled(person.id!),
            ),
        ],
      ),
      _ => Column(
        children: [
          for (var i = 0; i < _skeletonRows; i++) const _SkeletonRow(),
        ],
      ),
    };
  }
}

/// A centered message in the card, with an optional Retry.
class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.all(AppSpacing.s24),
      child: Column(
        children: [
          AppText(
            text,
            style: context.text.subtitle,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                minimumSize: const Size(
                  AuthDimens.tapTarget,
                  AuthDimens.tapTarget,
                ),
                foregroundColor: colors.primary,
              ),
              child: AppText(
                context.l10n.retry,
                style: context.text.name,
                color: colors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(AppSpacing.cardMargin),
    child: Row(
      children: [
        SkeletonPill(
          width: AuthDimens.avatarList,
          height: AuthDimens.avatarList,
        ),
        SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s8,
            children: [
              SkeletonPill(
                width: AuthDimens.followSkeletonName,
                height: AuthDimens.skeletonLineHeight,
              ),
              SkeletonPill(
                width: AuthDimens.followSkeletonMeta,
                height: AuthDimens.skeletonLineHeight,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
