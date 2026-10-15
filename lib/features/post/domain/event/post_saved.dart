import '../../../../core/utils/equatable.dart';
import '../entity/post_entity.dart';

/// A post was shared or edited, with the post as it is now. Home puts it in the feed without loading again.
/// Sent on the `EventBus`.
class PostSaved extends Equatable {
  const PostSaved(this.post);

  final PostEntity post;

  @override
  List<Object?> get props => [post];
}
