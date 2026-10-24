import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import 'post_model.dart';

/// One page of the home feed. [nextBeforeCreated] and [nextBeforeId] are the cursor for the next page;
/// both are null on the last page.
class FeedPageModel extends Equatable {
  final List<PostModel> posts;
  final DateTime? nextBeforeCreated;
  final String? nextBeforeId;

  const FeedPageModel({
    required this.posts,
    this.nextBeforeCreated,
    this.nextBeforeId,
  });

  /// The copy kept on the device. Posts hold storage paths only; a signed link is never part of it.
  factory FeedPageModel.fromJson(Map<String, dynamic> json) => FeedPageModel(
    posts:
        JsonMapper.list(
          json['posts'],
          (item) =>
              item is Map<String, dynamic> ? PostModel.fromJson(item) : null,
        ) ??
        const [],
    nextBeforeCreated: JsonMapper.date(json['next_before_created']),
    nextBeforeId: JsonMapper.string(json['next_before_id']),
  );

  Map<String, dynamic> toJson() => {
    'posts': posts.map((post) => post.toJson()).toList(),
    'next_before_created': nextBeforeCreated?.toIso8601String(),
    'next_before_id': nextBeforeId,
  };

  @override
  List<Object?> get props => [posts, nextBeforeCreated, nextBeforeId];
}
