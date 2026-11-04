import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/notice_context.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/author_prefs/author_prefs_cubit.dart';
import '../cubit/author_prefs/author_prefs_state.dart';
import '../cubit/other_profile/other_profile_cubit.dart';
import '../utils/profile_link.dart';

abstract final class ProfileSheets {
  static Future<void> following(BuildContext context, OtherProfileCubit cubit) {
    final prefs = context.read<AuthorPrefsCubit>();
    unawaited(prefs.load());
    return AppBottomSheet.show<void>(
      context,
      title: cubit.state.page?.fullName ?? '',
      child: BlocProvider.value(
        value: prefs,
        child: _Following(cubit: cubit),
      ),
    );
  }

  static Future<void> options(
    BuildContext context,
    OtherProfileCubit cubit,
  ) async {
    final l = context.l10n;
    final prefs = context.read<AuthorPrefsCubit>();
    final choice = await AppBottomSheet.show<int>(
      context,
      title: l.otherOptions,
      child: Builder(
        builder: (sheetContext) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SettingsRow(
                title: l.profileShare,
                icon: AppAssets.shareForward,
                onTap: () => AppNavigator.back(sheetContext, 0),
              ),
              SettingsRow(
                title: l.profileCopyLink,
                icon: AppAssets.link,
                onTap: () => AppNavigator.back(sheetContext, 1),
              ),
              SettingsRow(
                title: l.profileMute,
                icon: AppAssets.volumeOff,
                onTap: () => AppNavigator.back(sheetContext, 2),
              ),
              SettingsRow(
                title: l.profileBlock(cubit.state.page?.username ?? ''),
                icon: AppAssets.block,
                onTap: () => AppNavigator.back(sheetContext, 3),
              ),
              SettingsRow(
                title: l.profileReport,
                icon: AppAssets.flag,
                onTap: () => AppNavigator.back(sheetContext, 4),
              ),
            ],
          ),
        ),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case 0:
        await prefs.share();
      case 1:
        await Clipboard.setData(ClipboardData(text: profileLink(cubit.userId)));
        Notices.success(l.profileLinkCopied);
      case 2:
        unawaited(prefs.load());
        await AppBottomSheet.show<void>(
          context,
          title: l.profileMute,
          child: BlocProvider.value(
            value: prefs,
            child: _Following(cubit: cubit, muteOnly: true),
          ),
        );
      case 3:
        final confirmed = await ConfirmationDialog.destructive(
          context,
          icon: AppAssets.block,
          title: l.profileBlockTitle(cubit.state.page?.username ?? ''),
          message: l.profileBlockBody,
          confirmLabel: l.profileBlockAction,
          cancelLabel: l.cancel,
        );
        if (confirmed == true) {
          await cubit.block();
          if (cubit.state.failure == null) Notices.success(l.otherBlockedTitle);
        }
      case 4:
        await ReportSheet.show(
          context,
          copy: ReportCopy(
            title: l.profileReportTitle,
            body: l.profileReportBody,
            sentBody: l.profileReportSent,
            notePlaceholder: l.profileReportNote,
          ),
          onSubmit: (reason, note) => prefs.report(reason, note),
        );
      case null:
        break;
    }
  }
}

class _Following extends StatelessWidget {
  const _Following({required this.cubit, this.muteOnly = false});
  final OtherProfileCubit cubit;
  final bool muteOnly;

  Future<void> _unfollow(BuildContext context) async {
    final l = context.l10n;
    if (cubit.state.page?.isPrivate == true) {
      final confirmed = await ConfirmationDialog.destructive(
        context,
        icon: AppAssets.userMinus,
        title: l.otherUnfollowTitle(cubit.state.page?.fullName ?? ''),
        message: l.otherUnfollowBody,
        confirmLabel: l.otherUnfollow,
        cancelLabel: l.cancel,
      );
      if (confirmed != true || !context.mounted) return;
    }
    AppNavigator.back(context);
    await cubit.toggleFollow();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocConsumer<AuthorPrefsCubit, AuthorPrefsState>(
      listenWhen: (a, b) => a.failure != b.failure && b.failure != null,
      listener: (context, state) => context.showFailure(state.failure),
      builder: (context, state) {
        final values = state.values;
        if (values == null) {
          if (state.failure != null) {
            return AppEmpty.failed(
              onRetry: context.read<AuthorPrefsCubit>().load,
            );
          }
          return const AppInlineLoading.refresh();
        }
        final prefs = context.read<AuthorPrefsCubit>();
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!muteOnly) ...[
                SwitchRow(
                  title: l.profileCloseFriends,
                  subtitle: l.profileCloseFriendsSub,
                  value: values[0],
                  onChanged: state.busy ? null : (v) => prefs.change(0, v),
                ),
                SwitchRow(
                  title: l.profilePostNotifications,
                  subtitle: l.profilePostNotificationsSub,
                  value: values[1],
                  onChanged: state.busy ? null : (v) => prefs.change(1, v),
                ),
              ],
              SwitchRow(
                title: l.profileMute,
                subtitle: l.profileMuteSub,
                value: values[2] && values[3],
                onChanged: state.busy ? null : (v) => prefs.change(2, v),
              ),
              if (!muteOnly)
                SettingsRow(
                  title: l.otherUnfollow,
                  icon: AppAssets.userMinus,
                  onTap: () => _unfollow(context),
                ),
            ],
          ),
        );
      },
    );
  }
}
