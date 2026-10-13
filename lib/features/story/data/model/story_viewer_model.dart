import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A row of `story_viewers()`: someone who viewed one of your stories. [total] is the story's full view
/// count, repeated on every row.
class StoryViewerModel extends Equatable {
  final String? userId;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? viewedAt;
  final bool? liked;
  final int? total;

  const StoryViewerModel({
    this.userId,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.viewedAt,
    this.liked,
    this.total,
  });

  factory StoryViewerModel.fromJson(Map<String, dynamic> json) =>
      StoryViewerModel(
        userId: JsonMapper.string(json['user_id']),
        username: JsonMapper.string(json['username']),
        fullName: JsonMapper.string(json['full_name']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
        viewedAt: JsonMapper.date(json['viewed_at']),
        liked: JsonMapper.boolean(json['liked']),
        total: JsonMapper.integer(json['total']),
      );

  @override
  List<Object?> get props => [
    userId,
    username,
    fullName,
    avatarUrl,
    viewedAt,
    liked,
    total,
  ];
}
