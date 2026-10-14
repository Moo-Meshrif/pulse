import '../../../../core/utils/equatable.dart';

/// How many people each audience choice reaches: your accepted followers, your close friends and the
/// people hidden from you.
class AudienceSummaryEntity extends Equatable {
  final int followers;
  final int closeFriends;
  final int hidden;

  const AudienceSummaryEntity({
    this.followers = 0,
    this.closeFriends = 0,
    this.hidden = 0,
  });

  @override
  List<Object?> get props => [followers, closeFriends, hidden];
}
