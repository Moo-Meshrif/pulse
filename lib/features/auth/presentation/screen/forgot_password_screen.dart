import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/snack_bar_context.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_navigator.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../view/forgot_password_view.dart';
import '../widgets/reset_link_sent_dialog.dart';

/// `/forgot-password` (docs/specs/auth/screens/s2-forgot-password.md).
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ForgotPasswordCubit>(),
    // Two independent effects (a failure snackbar, the "link sent" dialog), each with its own
    // `listenWhen`. `BlocConsumer` takes a single listener, so one would have to branch on the state;
    // `MultiBlocListener` plus a `BlocBuilder` keeps them separate.
    child: MultiBlocListener(
      listeners: [
        BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
          listenWhen: (previous, state) =>
              state.failure != null && previous.failure != state.failure,
          listener: (context, state) => context.showFailure(state.failure),
        ),
        BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
          listenWhen: (_, state) => state.sentTo != null,
          listener: (context, state) {
            ResetLinkSentDialog.show(
              context,
              cubit: context.read<ForgotPasswordCubit>(),
            );
          },
        ),
      ],
      child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
        builder: (context, state) {
          final cubit = context.read<ForgotPasswordCubit>();
          return ForgotPasswordView(
            state: state,
            onEmailChanged: cubit.emailChanged,
            onSubmit: cubit.submit,
            onBack: () => AppNavigator.back(context),
          );
        },
      ),
    ),
  );
}
