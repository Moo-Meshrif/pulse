import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/state/base_cubit.dart';
import '../../data/datasource/auth_datasource.dart';
import 'reset_password_state.dart';

/// Set a new password (S11) and its "Password updated" dialog (S12), opened by the emailed recovery link
/// (docs/specs/auth/screens/s11-set-new-password.md).
@injectable
class ResetPasswordCubit extends BaseCubit<ResetPasswordState> {
  ResetPasswordCubit(this._auth)
    : super(ResetPasswordState(email: _auth.currentEmail)) {
    // The link can open this screen a moment before the recovery session exists.
    _recovery = _auth.passwordRecovery.listen(
      (_) => emit(state.copyWith(email: _auth.currentEmail)),
    );
  }

  final AuthDatasource _auth;

  late final StreamSubscription<Object?> _recovery;

  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, failure: null));

  void confirmChanged(String value) =>
      emit(state.copyWith(confirm: value, failure: null));

  void logoutOthersChanged(bool value) =>
      emit(state.copyWith(logoutOthers: value));

  Future<void> submit() async {
    await run(
      prevent: !state.canSubmit,
      loading: state.copyWith(loading: true, failure: null),
      () => _auth.updatePassword(state.password),
      onSuccess: (_) async {
        // The password is already changed: failing to sign out the others only changes what the dialog says.
        final others = state.logoutOthers && await _signOutOthers();
        return state.copyWith(
          loading: false,
          updated: true,
          othersLoggedOut: others,
        );
      },
      onFailure: (failure) => state.copyWith(loading: false, failure: failure),
    );
  }

  Future<bool> _signOutOthers() async {
    try {
      await _auth.signOut(others: true);
      return true;
    } on Failure {
      return false;
    }
  }

  /// The X and the dialog's "Sign in": ends the recovery session and opens Sign in. The session is dropped
  /// on this device even when the server cannot be reached.
  Future<void> leave() async {
    emit(state.copyWith(loading: true));
    try {
      await _auth.signOut();
    } on Failure {
      // Dropped on this device regardless.
    }
    emit(state.copyWith(loading: false, route: AppRoutes.signIn));
    emit(state.copyWith(route: null));
  }

  @override
  Future<void> close() {
    unawaited(_recovery.cancel());
    return super.close();
  }
}
