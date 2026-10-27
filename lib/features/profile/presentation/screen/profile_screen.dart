import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/notice_context.dart';
import '../cubit/profile/profile_cubit.dart';
import '../cubit/profile/profile_state.dart';
import '../view/profile_view.dart';

/// The Profile tab's root page: your own profile (docs/specs/profile/screens/s1-profile.md).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  bool _hasNewRefreshFailure(ProfileState before, ProfileState state) =>
      state.refreshFailure != null &&
      state.refreshFailure != before.refreshFailure;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ProfileCubit>()..load(),
    child: BlocListener<ProfileCubit, ProfileState>(
      listenWhen: _hasNewRefreshFailure,
      listener: (context, state) => context.showFailure(state.refreshFailure),
      child: const ProfileView(),
    ),
  );
}
