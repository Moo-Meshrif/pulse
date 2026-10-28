import '../../../../core/utils/equatable.dart';

/// The signed-in user's own profile was saved (Personal info). Sent on the `EventBus`; the Profile tab
/// reloads its header.
class ProfileUpdated extends Equatable {
  const ProfileUpdated();

  @override
  List<Object?> get props => const [];
}
