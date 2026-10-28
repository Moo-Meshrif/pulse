import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/enums/notification_pref.dart';
import '../cubit/notifications/notifications_cubit.dart';
import '../cubit/notifications/notifications_state.dart';

/// One switch of the Notifications page; rebuilds only when its own value changes.
class NotificationSwitch extends StatelessWidget {
  const NotificationSwitch({
    super.key,
    required this.pref,
    required this.title,
    required this.subtitle,
  });

  final NotificationPref pref;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<NotificationsCubit, NotificationsState, bool>(
        selector: (state) => state.prefs?[pref] ?? pref.defaultValue,
        builder: (context, value) => SwitchRow(
          title: title,
          subtitle: subtitle,
          value: value,
          onChanged: (next) =>
              context.read<NotificationsCubit>().toggle(pref, next),
        ),
      );
}
