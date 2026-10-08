import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_navigator.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';
import '../view/splash_view.dart';

/// `/` after onboarding: resolves the first route and replaces itself with it
/// (docs/specs/auth/screens/s13-splash.md).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<SplashCubit>()..decide(),
    child: BlocConsumer<SplashCubit, SplashState>(
      listenWhen: (_, state) => state.route != null,
      listener: (context, state) => AppNavigator.resetTo(context, state.route!),
      builder: (context, state) =>
          SplashView(state: state, onRetry: context.read<SplashCubit>().retry),
    ),
  );
}
