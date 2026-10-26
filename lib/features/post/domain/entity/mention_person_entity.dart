import '../../../../core/utils/equatable.dart';

/// Someone who can be mentioned in a comment.
class MentionPersonEntity extends Equatable {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;

  const MentionPersonEntity({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl];
}
