import '../../../../core/utils/equatable.dart';

/// Where the next feed page starts: the last post of the page before.
class FeedCursorEntity extends Equatable {
  final DateTime createdAt;
  final String id;

  const FeedCursorEntity({required this.createdAt, required this.id});

  @override
  List<Object?> get props => [createdAt, id];
}
