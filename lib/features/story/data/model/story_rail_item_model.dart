import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A row of `story_rail()`: one person with active stories.
class StoryRailItemModel extends Equatable {
  final String? authorId;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final bool? isMe;
  final int? storyCount;
  final DateTime? latestAt;
  final bool? allSeen;

  const StoryRailItemModel({
    this.authorId,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.isMe,
    this.storyCount,
    this.latestAt,
    this.allSeen,
  });

  factory StoryRailItemModel.fromJson(Map<String, dynamic> json) =>
      StoryRailItemModel(
        authorId: JsonMapper.string(json['author_id']),
        username: JsonMapper.string(json['username']),
        fullName: JsonMapper.string(json['full_name']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
        isMe: JsonMapper.boolean(json['is_me']),
        storyCount: JsonMapper.integer(json['story_count']),
        latestAt: JsonMapper.date(json['latest_at']),
        allSeen: JsonMapper.boolean(json['all_seen']),
      );

  /// The row of `story_rail()` again, for the copy kept on the device.
  Map<String, dynamic> toJson() => {
    'author_id': authorId,
    'username': username,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'is_me': isMe,
    'story_count': storyCount,
    'latest_at': latestAt?.toIso8601String(),
    'all_seen': allSeen,
  };

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
