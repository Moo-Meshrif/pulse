import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/notice_context.dart';
import '../cubit/notifications/notifications_cubit.dart';
import '../cubit/notifications/notifications_state.dart';
import '../view/notifications_view.dart';

/// `/settings/notifications` (docs/specs/profile/screens/s7-notifications.md): provides the cubit and
/// shows a failed save once.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<NotificationsCubit>()..load(),
    child: BlocListener<NotificationsCubit, NotificationsState>(
      listenWhen: (before, now) =>
          now.failure != null && now.failure != before.failure,
      listener: (context, state) => context.showFailure(state.failure),
      child: const NotificationsView(),
    ),
  );
}
