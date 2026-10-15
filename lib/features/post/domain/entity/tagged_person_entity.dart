import '../../../../core/utils/equatable.dart';
import '../../data/enums/follow_state.dart';

/// Someone tagged on a post and how you stand with them.
class TaggedPersonEntity extends Equatable {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final FollowState followState;

  const TaggedPersonEntity({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    required this.followState,
  });

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl, followState];
}
