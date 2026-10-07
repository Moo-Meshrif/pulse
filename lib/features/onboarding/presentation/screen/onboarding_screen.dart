import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/onboarding_cubit.dart';
import '../utils/enums/onboarding_exit.dart';
import '../view/onboarding_view.dart';

/// Route target of the onboarding flow. Every way out (Skip, Get started, Sign in) records
/// that onboarding was seen, then replaces the whole stack so Back never returns here.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<OnboardingCubit>(),
    child: BlocListener<OnboardingCubit, OnboardingExit?>(
      listener: (context, exit) {
        if (exit == null) return;
        AppNavigator.resetTo(context, switch (exit) {
          OnboardingExit.signIn => AppRoutes.signIn,
          OnboardingExit.register => AppRoutes.register,
        });
      },
      child: Builder(
        builder: (context) {
          final cubit = context.read<OnboardingCubit>();
          return OnboardingView(
            onSkip: () => cubit.finish(OnboardingExit.signIn),
            onGetStarted: () => cubit.finish(OnboardingExit.register),
            onSignIn: () => cubit.finish(OnboardingExit.signIn),
          );
        },
      ),
    ),
  );
}
