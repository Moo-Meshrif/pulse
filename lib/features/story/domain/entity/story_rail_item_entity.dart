import '../../../../core/utils/equatable.dart';

/// One person on the story rail. Public: Home draws the rail from it.
class StoryRailItemEntity extends Equatable {
  final String authorId;
  final String username;
  final String? fullName;
  final String? avatarUrl;

  /// This is you (only listed when you have an active story).
  final bool isMe;
  final int storyCount;
  final DateTime? latestAt;

  /// Every story of this person was seen by you: the ring turns to its seen look.
  final bool allSeen;

  const StoryRailItemEntity({
    required this.authorId,
    required this.username,
    this.fullName,
    this.avatarUrl,
    required this.isMe,
    required this.storyCount,
    this.latestAt,
    required this.allSeen,
  });

  @override
  List<Object?> get props => [
    authorId,
    username,
    fullName,
    avatarUrl,
    isMe,
    storyCount,
    latestAt,
    allSeen,
  ];
}
