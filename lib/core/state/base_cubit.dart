import 'package:flutter_bloc/flutter_bloc.dart';

/// Base for the app's Cubits. Emits only while open, so emitting after an `await` (the user left the
/// screen) never throws.
abstract class BaseCubit<S> extends Cubit<S> {
  BaseCubit(super.initialState);

  @override
  void emit(S state) {
    if (isClosed) return;
    super.emit(state);
  }
}
