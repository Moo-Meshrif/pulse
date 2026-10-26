import '../../../../core/utils/equatable.dart';

/// A comment you wrote that the server has not confirmed: being sent, or failed and waiting for Retry or
/// Delete. [clientId] is sent with every attempt, so a retry writes once.
class PendingComment extends Equatable {
  final String clientId;
  final String body;

  /// The top-level comment this is a reply to; null for a top-level comment.
  final String? parentId;
  final bool failed;

  const PendingComment({
    required this.clientId,
    required this.body,
    this.parentId,
    this.failed = false,
  });

  PendingComment copyWith({bool? failed}) => PendingComment(
    clientId: clientId,
    body: body,
    parentId: parentId,
    failed: failed ?? this.failed,
  );

  @override
  List<Object?> get props => [clientId, body, parentId, failed];
}
