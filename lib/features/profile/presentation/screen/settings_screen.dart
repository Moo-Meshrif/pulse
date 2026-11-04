import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/notice_context.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/settings/settings_cubit.dart';
import '../cubit/settings/settings_state.dart';
import '../view/settings_view.dart';

/// `/settings` (docs/specs/profile/screens/s2-settings.md): provides the cubit, shows a failed log out
/// or delete, and leaves to Sign in once the session is gone.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<SettingsCubit>()..load(),
    child: BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (before, now) =>
          (now.signedOut && !before.signedOut) ||
          (now.failure != null && now.failure != before.failure),
      listener: (context, state) => state.signedOut
          ? AppNavigator.resetTo(context, AppRoutes.signIn, rootNavigator: true)
          : context.showFailure(state.failure),
      child: const SettingsView(),
    ),
  );
}
