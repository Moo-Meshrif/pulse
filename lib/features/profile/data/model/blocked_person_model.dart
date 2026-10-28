import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A row of `blocked_users`: a person the caller blocked. [blockedAt] and [id] together are the paging
/// cursor.
class BlockedPersonModel extends Equatable {
  const BlockedPersonModel({
    this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.isVerified,
    this.blockedAt,
  });

  factory BlockedPersonModel.fromJson(Map<String, dynamic> json) =>
      BlockedPersonModel(
        id: JsonMapper.string(json['id']),
        username: JsonMapper.string(json['username']),
        fullName: JsonMapper.string(json['full_name']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
        isVerified: JsonMapper.boolean(json['is_verified']),
        blockedAt: DateTime.tryParse(JsonMapper.string(json['sort_at']) ?? '')
            ?.toUtc(),
      );

  final String? id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final bool? isVerified;
  final DateTime? blockedAt;

  /// The full name, or the @username when there is none.
  String get displayName {
    final name = fullName?.trim();
    return name == null || name.isEmpty ? (username ?? '') : name;
  }

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    avatarUrl,
    isVerified,
    blockedAt,
  ];
}
