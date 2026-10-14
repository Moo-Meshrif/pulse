import '../../../../core/utils/equatable.dart';
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

  @override
  List<Object?> get props => [posts, nextBeforeCreated, nextBeforeId];
}
