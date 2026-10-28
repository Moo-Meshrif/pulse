import '../../../../../core/utils/equatable.dart';

/// How the signed-in person's own posts and Stories item show them. All null until the profile is read.
class OwnAuthorState extends Equatable {
  const OwnAuthorState({this.id, this.username, this.fullName, this.avatarUrl});

  final String? id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl];
}
