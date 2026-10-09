import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/snack_bar_context.dart';
import '../../../../core/router/app_navigator.dart';
import '../cubit/sign_in_cubit.dart';
import '../cubit/sign_in_state.dart';
import '../view/sign_in_view.dart';

/// `/sign-in`: provides [SignInCubit], follows its destination (Home, a sign-up step, or the Verify
/// email step) and shows its failures. The view only builds (docs/specs/auth/screens/s1-signin.md).
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<SignInCubit>(),
    child: BlocListener<SignInCubit, SignInState>(
      listenWhen: _hasRouteOrNewFailure,
      listener: _navigateOrShowFailure,
      child: const SignInView(),
    ),
  );

  // Navigation and failures are one-shot effects; typing must not trigger them again.
  bool _hasRouteOrNewFailure(SignInState before, SignInState state) =>
      state.route != null ||
      (state.failure != null && state.failure != before.failure);

  void _navigateOrShowFailure(BuildContext context, SignInState state) {
    final route = state.route;
    if (route == null) {
      context.showFailure(state.failure);
      return;
    }
    state.clearStack
        ? AppNavigator.resetTo(context, route)
        : AppNavigator.push(context, route);
  }
}
