import '../../../../core/utils/equatable.dart';
import '../utils/enums/splash_problem.dart';

/// What the splash shows: it is deciding (loading), it decided ([route]) or it could not ([problem]).
class SplashState extends Equatable {
  const SplashState.deciding() : route = null, problem = null;
  const SplashState.go(String this.route) : problem = null;
  const SplashState.failed(SplashProblem this.problem) : route = null;

  /// Where the app goes next; null until decided.
  final String? route;

  /// Set when the decision failed; the screen offers "Try again".
  final SplashProblem? problem;

  @override
  List<Object?> get props => [route, problem];
}
