import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A row returned by `follow_requests`: someone waiting for the signed-in user to accept their follow.
/// Presentation uses it directly (the app's concept matches the row).
class FollowRequestModel extends Equatable {
  final String? id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? city;
  final int? mutualCount;
  final DateTime? requestedAt;

  const FollowRequestModel({
    this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.city,
    this.mutualCount,
    this.requestedAt,
  });

  factory FollowRequestModel.fromJson(Map<String, dynamic> json) =>
      FollowRequestModel(
        id: JsonMapper.string(json['id']),
        username: JsonMapper.string(json['username']),
        fullName: JsonMapper.string(json['full_name']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
        city: JsonMapper.string(json['city']),
        mutualCount: JsonMapper.integer(json['mutual_count']),
        requestedAt: JsonMapper.date(json['requested_at']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'city': city,
    'mutual_count': mutualCount,
    'requested_at': requestedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    avatarUrl,
    city,
    mutualCount,
    requestedAt,
  ];
}
