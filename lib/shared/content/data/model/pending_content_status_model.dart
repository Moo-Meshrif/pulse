import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/pending_content_state.dart';

/// A row of `content_status`: where one of the signed-in user's items is on the server, with the files
/// it still waits for while it is shared.
class PendingContentStatusModel extends Equatable {
  final String? id;
  final PendingContentState? state;

  /// The SQLSTATE of a rejected publish.
  final String? errorCode;

  /// Object paths that are not in storage yet, or not as shared (owner, size, type).
  final List<String>? missing;

  const PendingContentStatusModel({
    this.id,
    this.state,
    this.errorCode,
    this.missing,
  });

  factory PendingContentStatusModel.fromJson(Map<String, dynamic> json) =>
      PendingContentStatusModel(
        id: JsonMapper.string(json['id']),
        state: PendingContentState.fromWire(json['state']),
        errorCode: JsonMapper.string(json['error_code']),
        missing: JsonMapper.list(json['missing'], JsonMapper.string),
      );

  @override
  List<Object?> get props => [id, state, errorCode, missing];
}
