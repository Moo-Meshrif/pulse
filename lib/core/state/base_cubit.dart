import 'package:flutter_bloc/flutter_bloc.dart';

/// Base for the app's Cubits. Emits only while the Cubit is open, so emitting after an
/// `await` (the user left the screen) never throws a `StateError`.
///
/// Deliberately minimal: `run()` (Either → state, a `CancelToken` per call) joins it when
/// the first backend feature adds `Failure` / `Either` / Dio.
abstract class BaseCubit<S> extends Cubit<S> {
  BaseCubit(super.initialState);

  @override
  void emit(S state) {
    if (isClosed) return;
    super.emit(state);
  }
}
