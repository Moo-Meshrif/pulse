import '../../../../core/utils/equatable.dart';

/// The Stories rail should load again (after a mute). Sent on the `EventBus`.
class StoryRailChanged extends Equatable {
  const StoryRailChanged();

  @override
  List<Object?> get props => const [];
}
