import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/snack_bar_context.dart';
import '../../../../core/router/app_navigator.dart';
import '../cubit/sign_up_cubit.dart';
import '../cubit/sign_up_state.dart';
import '../view/sign_up_view.dart';

/// `/register`: provides [SignUpCubit] for the whole flow and runs its one-shot effects (leave the flow,
/// failure toast); the view only builds (docs/specs/auth/00-overview.md). [step] and [email] open it
/// mid-way: a resumed sign-up, or Sign in finding an unverified account.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({
    super.key,
    this.step = SignUpCubit.firstStep,
    this.email,
  });

  final int step;
  final String? email;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<SignUpCubit>()..open(step: step, email: email),
    child: BlocListener<SignUpCubit, SignUpState>(
      listenWhen: _hasRouteOrNewToastFailure,
      listener: _leaveFlowOrShowFailure,
      child: const SignUpView(),
    ),
  );

  // One-shot effects; typing must not trigger them again.
  bool _hasRouteOrNewToastFailure(SignUpState before, SignUpState state) =>
      state.route != null ||
      (state.toastFailure != null && state.failure != before.failure);

  void _leaveFlowOrShowFailure(BuildContext context, SignUpState state) {
    final route = state.route;
    if (route != null) {
      AppNavigator.resetTo(context, route);
      return;
    }
    context.showFailure(state.toastFailure);
  }
}
