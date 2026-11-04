import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/enums/comment_audience.dart';
import '../../data/enums/message_audience.dart';
import '../cubit/privacy/privacy_cubit.dart';
import '../cubit/privacy/privacy_state.dart';

/// The Privacy page: the private switch, two radio groups and the visibility group.
class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = NavClearance.of(context) + AppSpacing.s32;
    return AppPage(
      backgroundColor: context.appColors.background,
      title: context.l10n.privacyTitle,
      bottomSpace: bottom,
      child: BlocBuilder<PrivacyCubit, PrivacyState>(
        buildWhen: (before, now) =>
            (before.settings == null) != (now.settings == null) ||
            before.loadFailed != now.loadFailed,
        builder: (context, state) {
          if (state.settings == null) {
            return state.loadFailed
                ? AppEmpty.failed(onRetry: context.read<PrivacyCubit>().load)
                : const AppLoadingView();
          }
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: AppSpacing.s16, bottom: bottom),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PrivateGroup(),
                _MessageGroup(),
                _CommentGroup(),
                _VisibilityGroup(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PrivateGroup extends StatelessWidget {
  const _PrivateGroup();

  @override
  Widget build(BuildContext context) => SettingsGroup(
    children: [
      BlocSelector<PrivacyCubit, PrivacyState, bool>(
        selector: (state) => state.settings?.isPrivate ?? false,
        builder: (context, value) => SwitchRow(
          title: context.l10n.privateAccount,
          subtitle: context.l10n.privateAccountSub,
          value: value,
          onChanged: context.read<PrivacyCubit>().setPrivate,
        ),
      ),
    ],
  );
}

class _MessageGroup extends StatelessWidget {
  const _MessageGroup();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocSelector<PrivacyCubit, PrivacyState, MessageAudience>(
      selector: (state) =>
          state.settings?.whoCanMessage ?? MessageAudience.everyone,
      builder: (context, selected) => SettingsGroup(
        label: l10n.whoCanMessage,
        children: [
          for (final (audience, title) in [
            (MessageAudience.everyone, l10n.everyone),
            (MessageAudience.following, l10n.peopleYouFollow),
            (MessageAudience.none, l10n.noOne),
          ])
            RadioRow(
              title: title,
              selected: selected == audience,
              onTap: () =>
                  context.read<PrivacyCubit>().setWhoCanMessage(audience),
            ),
        ],
      ),
    );
  }
}

class _CommentGroup extends StatelessWidget {
  const _CommentGroup();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocSelector<PrivacyCubit, PrivacyState, CommentAudience>(
      selector: (state) =>
          state.settings?.whoCanComment ?? CommentAudience.everyone,
      builder: (context, selected) => SettingsGroup(
        label: l10n.whoCanComment,
        children: [
          for (final (audience, title) in [
            (CommentAudience.everyone, l10n.everyone),
            (CommentAudience.followers, l10n.followersOnly),
            (CommentAudience.none, l10n.turnOffComments),
          ])
            RadioRow(
              title: title,
              selected: selected == audience,
              onTap: () =>
                  context.read<PrivacyCubit>().setWhoCanComment(audience),
            ),
        ],
      ),
    );
  }
}

class _VisibilityGroup extends StatelessWidget {
  const _VisibilityGroup();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsGroup(
      label: l10n.visibility,
      children: [
        BlocSelector<PrivacyCubit, PrivacyState, bool>(
          selector: (state) => state.settings?.showActivity ?? true,
          builder: (context, value) => SwitchRow(
            title: l10n.activityStatus,
            subtitle: l10n.activityStatusSub,
            value: value,
            onChanged: context.read<PrivacyCubit>().setShowActivity,
          ),
        ),
        BlocSelector<PrivacyCubit, PrivacyState, bool>(
          selector: (state) => state.settings?.appearInSearch ?? true,
          builder: (context, value) => SwitchRow(
            title: l10n.appearInSearch,
            subtitle: l10n.appearInSearchSub,
            value: value,
            onChanged: context.read<PrivacyCubit>().setAppearInSearch,
          ),
        ),
        BlocSelector<PrivacyCubit, PrivacyState, int?>(
          selector: (state) => state.blockedCount,
          builder: (context, count) => SettingsRow(
            title: l10n.blockedAccounts,
            value: count?.toString(),
            onTap: () async {
              final cubit = context.read<PrivacyCubit>();
              await AppNavigator.push(context, AppRoutes.settingsBlocked);
              await cubit.reloadBlockedCount();
            },
          ),
        ),
      ],
    );
  }
}
