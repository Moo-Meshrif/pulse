import '../../../../core/utils/equatable.dart';

/// The home feed should load again: a post was shared with no author to show yet, or Home was tapped while
/// open. Sent on the `EventBus`; nobody hears it while no feed is on screen.
class FeedRefreshRequested extends Equatable {
  const FeedRefreshRequested();

  @override
  List<Object?> get props => const [];
}
