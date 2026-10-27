import '../../../../core/utils/equatable.dart';
import 'post_liker_model.dart';

/// A page of `post_likers()`. [nextLikedAt] and [nextId] are where the next page starts; null on the last page.
class PostLikersPageModel extends Equatable {
  final List<PostLikerModel> likers;
  final DateTime? nextLikedAt;
  final String? nextId;

  const PostLikersPageModel({
    required this.likers,
    this.nextLikedAt,
    this.nextId,
  });

  @override
  List<Object?> get props => [likers, nextLikedAt, nextId];
}
