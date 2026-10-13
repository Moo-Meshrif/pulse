import 'package:injectable/injectable.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../auth/domain/use_case/is_recovery_pending_use_case.dart';
import '../utils/enums/main_tab.dart';
import 'control_page_state.dart';

/// The main shell (docs/specs/control-page): which tab is selected and the Chat badge. Back and
/// re-tap act on the tabs' Navigators, so they live in the view.
@injectable
class ControlPageCubit extends BaseCubit<ControlPageState> {
  ControlPageCubit(this._isRecoveryPending)
    // TODO(control-page-plan T5): the chat unread count is hardcoded to 4; the chat feature must supply it.
    : super(const ControlPageState(chatUnread: 4));

  final IsRecoveryPendingUseCase _isRecoveryPending;

  /// A password reset that was started and not finished (the app was closed on its screen) resumes there:
  /// the shell must never stay on Home with a recovery session, as the splash does not (`SplashCubit`).
  Future<void> start() async {
    // Yield first: the screen calls this from `BlocProvider.create`, before its listener is subscribed.
    await Future<void>.value();
    if (_isRecoveryPending()) {
      emit(state.copyWith(redirect: AppRoutes.resetPassword));
    }
  }

  void select(MainTab tab) {
    if (tab != state.selected) emit(state.copyWith(selected: tab));
  }

  void goHome() => select(MainTab.home);
}
