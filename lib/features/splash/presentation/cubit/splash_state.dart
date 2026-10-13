import '../../../../core/utils/equatable.dart';
import '../utils/enums/splash_problem.dart';

/// What the splash shows: it is deciding (loading), it decided ([route]) or it could not ([problem]).
class SplashState extends Equatable {
  const SplashState.deciding()
    : route = null,
      problem = null,
      isRetrying = false;
  const SplashState.retrying(SplashProblem this.problem)
    : route = null,
      isRetrying = true;
  const SplashState.go(String this.route) : problem = null, isRetrying = false;
  const SplashState.failed(SplashProblem this.problem)
    : route = null,
      isRetrying = false;

  /// Where the app goes next; null until decided.
  final String? route;

  /// Set when the decision failed; the screen offers "Try again".
  final SplashProblem? problem;

  /// Whether the user has tapped "Try again" or not.
  final bool isRetrying;

  @override
  List<Object?> get props => [route, problem, isRetrying];
}
