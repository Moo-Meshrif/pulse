import '../../../../core/utils/equatable.dart';

/// A person in the tag search. [canTag] is false when their settings do not let you tag them.
class TagPersonEntity extends Equatable {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final bool canTag;

  const TagPersonEntity({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    required this.canTag,
  });

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl, canTag];
}
