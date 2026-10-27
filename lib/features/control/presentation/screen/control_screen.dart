import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../home/presentation/screen/home_screen.dart';
import '../../../profile/presentation/screen/profile_screen.dart';
import '../cubit/control_cubit.dart';
import '../cubit/control_state.dart';
import '../utils/enums/main_tab.dart';
import '../view/control_view.dart';
import '../widgets/tab_placeholder.dart';

/// `/home`: the main shell, the screen every signed-in session lands on
/// (docs/specs/control/screens/s0-glass-nav.md).
class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  /// Each tab's root page. Features hand over their screens here as they get built.
  static Widget _root(BuildContext context, MainTab tab) => switch (tab) {
    MainTab.home => const HomeScreen(),
    // TODO(control-page-plan T2): Shorts tab placeholder until the shorts feature is specced.
    // TODO(content-changes-plan T2): the shorts feed listens for `ContentChanged` of `ContentKind.short` (changes_since and posts_by_ids already serve shorts) and asks `CheckContentChangesUseCase(ContentKind.short)` when it opens and when the app returns.
    MainTab.shorts => const TabPlaceholder(tab: MainTab.shorts),
    // TODO(control-page-plan T3): Chat tab placeholder until the chat feature exists.
    MainTab.chat => const TabPlaceholder(tab: MainTab.chat),
    MainTab.profile => const ProfileScreen(),
  };

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ControlCubit>()..start(),
    child: BlocListener<ControlCubit, ControlState>(
      listenWhen: (_, state) => state.redirect != null,
      listener: (context, state) =>
          AppNavigator.resetTo(context, state.redirect!),
      child: const ControlView(rootBuilder: _root),
    ),
  );
}
