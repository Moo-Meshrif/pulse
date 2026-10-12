import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../cubit/splash_state.dart';
import '../widgets/splash_loading.dart';
import '../widgets/splash_problem_view.dart';

/// The splash's pure UI: loading while it decides, the offline / can't-reach screen when it could not
/// ([onRetry] runs the decision again).
class SplashView extends StatelessWidget {
  const SplashView({
    super.key,
    required this.state,
    required this.onRetry,
    required this.isRetrying,
  });

  final SplashState state;
  final VoidCallback onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final problem = state.problem;
    return AppPage(
      child: problem == null
          ? const SplashLoading()
          : SplashProblemView(
              problem: problem,
              onRetry: onRetry,
              isRetrying: isRetrying,
            ),
    );
  }
}
