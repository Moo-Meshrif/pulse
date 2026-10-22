import '../../../../core/utils/equatable.dart';

/// You have now seen every story of [authorId]: the rail turns that ring grey. Sent on the `EventBus`.
class StoryAuthorSeen extends Equatable {
  const StoryAuthorSeen(this.authorId);

  final String authorId;

  @override
  List<Object?> get props => [authorId];
}
