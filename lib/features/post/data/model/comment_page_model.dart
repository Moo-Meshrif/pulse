import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import 'comment_model.dart';

/// One page of a post's top-level comments. The three `next` values are the cursor for the next page;
/// all are null on the last page.
class CommentPageModel extends Equatable {
  final List<CommentModel> comments;
  final int? nextRank;
  final DateTime? nextCreated;
  final String? nextId;

  const CommentPageModel({
    required this.comments,
    this.nextRank,
    this.nextCreated,
    this.nextId,
  });

  /// The copy kept on the device.
  factory CommentPageModel.fromJson(Map<String, dynamic> json) =>
      CommentPageModel(
        comments:
            JsonMapper.list(
              json['comments'],
              (item) => item is Map<String, dynamic>
                  ? CommentModel.fromJson(item)
                  : null,
            ) ??
            const [],
        nextRank: JsonMapper.integer(json['next_rank']),
        nextCreated: JsonMapper.date(json['next_created']),
        nextId: JsonMapper.string(json['next_id']),
      );

  Map<String, dynamic> toJson() => {
    'comments': comments.map((comment) => comment.toJson()).toList(),
    'next_rank': nextRank,
    'next_created': nextCreated?.toUtc().toIso8601String(),
    'next_id': nextId,
  };

  @override
  List<Object?> get props => [comments, nextRank, nextCreated, nextId];
}
