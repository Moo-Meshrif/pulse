import 'package:injectable/injectable.dart';

import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../data/repository/profile_repository.dart';
import '../../../domain/entity/profile_entity.dart';
import '../../../domain/event/profile_updated.dart';
import 'own_author_state.dart';

/// The name and photo of the signed-in person, for every screen that draws them as an author (Home posts and
/// Stories item, later Shorts). A public export of `profile`, provided once by the control shell: a saved
/// Personal info shows at once, without loading a list again (which would move the person's place).
@injectable
class OwnAuthorCubit extends BaseCubit<OwnAuthorState>
    with EventCubitMixin<OwnAuthorState> {
  OwnAuthorCubit(this._profiles, this._events) : super(const OwnAuthorState());

  final ProfileRepository _profiles;
  final EventBus _events;

  @override
  EventBus get events => _events;

  /// Shows the saved copy at once (no request), and reads the server only when there is none yet.
  Future<void> start() async {
    listenTo<ProfileUpdated>((_) => _showSaved());
    if (!_showSaved()) await _loadFromServer();
  }

  /// A saved Personal info is already in the copy when `ProfileUpdated` arrives.
  bool _showSaved() {
    final next = _stateOf(_profiles.savedProfile());
    if (next == null) return false;
    emit(next);
    return true;
  }

  /// A failure keeps what is shown: the posts still carry the name and photo they came with.
  Future<void> _loadFromServer() =>
      run(_profiles.getProfile, onSuccess: _stateOf, onFailure: (_) => null);

  OwnAuthorState? _stateOf(ProfileEntity? profile) =>
      profile == null || profile.id == null || profile.username == null
      ? null
      : OwnAuthorState(
          id: profile.id,
          username: profile.username,
          fullName: profile.fullName,
          avatarUrl: profile.avatarUrl,
        );
}
