import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/content_change_op.dart';

/// One item that changed: what happened, its id and when.
class ContentChangeModel extends Equatable {
  final ContentChangeOp? op;
  final String? id;
  final DateTime? at;

  const ContentChangeModel({this.op, this.id, this.at});

  factory ContentChangeModel.fromJson(Map<String, dynamic> json) =>
      ContentChangeModel(
        op: ContentChangeOp.fromWire(json['op']),
        id: JsonMapper.string(json['id']),
        at: JsonMapper.date(json['at']),
      );

  @override
  List<Object?> get props => [op, id, at];
}

/// The answer of `changes_since`: a page of changes and the point to continue from.
class ContentChangesModel extends Equatable {
  /// True when the phone must load normally (no point, too old, or too far behind).
  final bool? reset;
  final List<ContentChangeModel>? ops;
  final DateTime? nextAt;
  final String? nextId;
  final bool? hasMore;

  const ContentChangesModel({
    this.reset,
    this.ops,
    this.nextAt,
    this.nextId,
    this.hasMore,
  });

  factory ContentChangesModel.fromJson(Map<String, dynamic> json) =>
      ContentChangesModel(
        reset: JsonMapper.boolean(json['reset']),
        ops: JsonMapper.list(
          json['ops'],
          (item) => item is Map<String, dynamic>
              ? ContentChangeModel.fromJson(item)
              : null,
        ),
        nextAt: JsonMapper.date(json['next_at']),
        nextId: JsonMapper.string(json['next_id']),
        hasMore: JsonMapper.boolean(json['has_more']),
      );

  @override
  List<Object?> get props => [reset, ops, nextAt, nextId, hasMore];
}
