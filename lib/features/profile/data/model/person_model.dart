import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../../../follow/data/enums/follow_status.dart';

/// A row of `followers_of` / `following_of` / `mutual_followers`: a person in a list and where the
/// caller's follow of them stands. [sortAt] and [id] together are the paging cursor.
class PersonModel extends Equatable {
  final String? id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final bool? isVerified;
  final FollowStatus? followStatus;
  final bool? followsMe;
  final DateTime? sortAt;

  const PersonModel({
    this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.isVerified,
    this.followStatus,
    this.followsMe,
    this.sortAt,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) => PersonModel(
    id: JsonMapper.string(json['id']),
    username: JsonMapper.string(json['username']),
    fullName: JsonMapper.string(json['full_name']),
    avatarUrl: JsonMapper.string(json['avatar_url']),
    isVerified: JsonMapper.boolean(json['is_verified']),
    followStatus: FollowStatus.fromJson(json['follow_status']),
    followsMe: JsonMapper.boolean(json['follows_me']),
    sortAt: DateTime.tryParse(JsonMapper.string(json['sort_at']) ?? '')
        ?.toUtc(),
  );

  /// The full name, or the @username when there is none.
  String get displayName {
    final name = fullName?.trim();
    return name == null || name.isEmpty ? (username ?? '') : name;
  }

  PersonModel withFollow(FollowStatus status) => PersonModel(
    id: id,
    username: username,
    fullName: fullName,
    avatarUrl: avatarUrl,
    isVerified: isVerified,
    followStatus: status,
    followsMe: followsMe,
    sortAt: sortAt,
  );

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    avatarUrl,
    isVerified,
    followStatus,
    followsMe,
    sortAt,
  ];
}
