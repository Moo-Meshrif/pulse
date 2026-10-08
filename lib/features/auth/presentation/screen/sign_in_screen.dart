import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/snack_bar_context.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/sign_in_cubit.dart';
import '../cubit/sign_in_state.dart';
import '../view/sign_in_view.dart';

/// `/sign-in`: provides [SignInCubit], follows its destination (Home, a sign-up step, or the Verify
/// email step) and opens Forgot password and Create account (docs/specs/auth/screens/s1-signin.md).
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<SignInCubit>(),
    child: BlocConsumer<SignInCubit, SignInState>(
      listenWhen: (before, state) =>
          state.route != null ||
          (state.failure != null && state.failure != before.failure),
      listener: (context, state) {
        if (state.route != null) {
          state.clearStack
              ? AppNavigator.resetTo(context, state.route!)
              : AppNavigator.push(context, state.route!);
          return;
        }
        context.showFailure(state.failure);
      },
      builder: (context, state) {
        final cubit = context.read<SignInCubit>();
        return SignInView(
          state: state,
          onIdentifierChanged: cubit.identifierChanged,
          onPasswordChanged: cubit.passwordChanged,
          onSubmit: cubit.submit,
          onForgotPassword: () =>
              AppNavigator.push(context, AppRoutes.forgotPassword),
          onCreateAccount: () => AppNavigator.push(context, AppRoutes.register),
        );
      },
    ),
  );
}
