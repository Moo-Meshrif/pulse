import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/suggestion_reason.dart';

/// A row returned by `suggested_profiles`: a person to follow on the last sign-up step. Presentation
/// uses it directly (the app's concept matches the row).
class SuggestedProfileModel extends Equatable {
  final String? id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? city;
  final SuggestionReason? reason;
  final int? mutualCount;
  final bool? isPrivate;

  const SuggestedProfileModel({
    this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.city,
    this.reason,
    this.mutualCount,
    this.isPrivate,
  });

  factory SuggestedProfileModel.fromJson(Map<String, dynamic> json) =>
      SuggestedProfileModel(
        id: JsonMapper.string(json['id']),
        username: JsonMapper.string(json['username']),
        fullName: JsonMapper.string(json['full_name']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
        city: JsonMapper.string(json['city']),
        reason: SuggestionReason.fromJson(json['reason_kind']),
        mutualCount: JsonMapper.integer(json['mutual_count']),
        isPrivate: JsonMapper.boolean(json['is_private']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'city': city,
    'reason_kind': reason?.value,
    'mutual_count': mutualCount,
    'is_private': isPrivate,
  };

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    avatarUrl,
    city,
    reason,
    mutualCount,
    isPrivate,
  ];
}
