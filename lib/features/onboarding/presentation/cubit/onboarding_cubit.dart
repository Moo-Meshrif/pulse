import 'package:injectable/injectable.dart';

import '../../../../core/state/base_cubit.dart';
import '../../data/datasource/onboarding_datasource.dart';
import '../utils/enums/onboarding_exit.dart';

/// Records that onboarding was seen, then reports how the user left. `null` until they leave.
/// The Cubit holds no route: the screen turns the exit into a navigation.
@injectable
class OnboardingCubit extends BaseCubit<OnboardingExit?> {
  OnboardingCubit(this._datasource) : super(null);

  final OnboardingDatasource _datasource;
  bool _finishing = false;

  Future<void> finish(OnboardingExit exit) async {
    if (_finishing) return; // a second tap while the flag is being written
    _finishing = true;
    await _datasource.markSeen();
    emit(exit);
  }
}
