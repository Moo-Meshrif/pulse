import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/enums/notification_pref.dart';
import '../cubit/notifications/notifications_cubit.dart';
import '../cubit/notifications/notifications_state.dart';
import '../widgets/notification_switch.dart';

/// The Notifications page: the push switch and three groups of switches.
class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = NavClearance.of(context) + AppSpacing.s32;
    return AppPage(
      backgroundColor: context.appColors.background,
      title: l10n.notificationsTitle,
      bottomSpace: bottom,
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        buildWhen: (before, now) =>
            (before.prefs == null) != (now.prefs == null) ||
            before.loadFailed != now.loadFailed,
        builder: (context, state) {
          if (state.prefs == null) {
            return state.loadFailed
                ? AppEmpty.failed(
                    onRetry: context.read<NotificationsCubit>().load,
                  )
                : const AppLoadingView();
          }
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: AppSpacing.s16, bottom: bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsGroup(
                  children: [
                    NotificationSwitch(
                      pref: NotificationPref.push,
                      title: l10n.notificationsPush,
                      subtitle: l10n.notificationsPushSub,
                    ),
                  ],
                ),
                SettingsGroup(
                  label: l10n.notificationsSectionActivity,
                  children: [
                    NotificationSwitch(
                      pref: NotificationPref.likes,
                      title: l10n.notificationsLikes,
                      subtitle: l10n.notificationsLikesSub,
                    ),
                    NotificationSwitch(
                      pref: NotificationPref.comments,
                      title: l10n.notificationsComments,
                      subtitle: l10n.notificationsCommentsSub,
                    ),
                    NotificationSwitch(
                      pref: NotificationPref.mentions,
                      title: l10n.notificationsMentions,
                      subtitle: l10n.notificationsMentionsSub,
                    ),
                    NotificationSwitch(
                      pref: NotificationPref.followers,
                      title: l10n.notificationsFollowers,
                      subtitle: l10n.notificationsFollowersSub,
                    ),
                  ],
                ),
                SettingsGroup(
                  label: l10n.notificationsSectionMessages,
                  children: [
                    NotificationSwitch(
                      pref: NotificationPref.messages,
                      title: l10n.notificationsDirect,
                      subtitle: l10n.notificationsDirectSub,
                    ),
                    NotificationSwitch(
                      pref: NotificationPref.groupChats,
                      title: l10n.notificationsGroups,
                      subtitle: l10n.notificationsGroupsSub,
                    ),
                  ],
                ),
                SettingsGroup(
                  label: l10n.notificationsSectionPulse,
                  children: [
                    NotificationSwitch(
                      pref: NotificationPref.shorts,
                      title: l10n.notificationsShorts,
                      subtitle: l10n.notificationsShortsSub,
                    ),
                    NotificationSwitch(
                      pref: NotificationPref.emailDigest,
                      title: l10n.notificationsDigest,
                      subtitle: l10n.notificationsDigestSub,
                    ),
                    NotificationSwitch(
                      pref: NotificationPref.product,
                      title: l10n.notificationsProduct,
                      subtitle: l10n.notificationsProductSub,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
