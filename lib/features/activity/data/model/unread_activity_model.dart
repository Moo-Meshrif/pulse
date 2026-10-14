import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// The row of `activity_unread_count()`: what is waiting for the signed-in person.
class UnreadActivityModel extends Equatable {
  /// Unread notifications (likes, comments, new followers…), follow requests not included.
  final int? activity;

  /// Follow requests waiting for an answer.
  final int? followRequests;

  const UnreadActivityModel({this.activity, this.followRequests});

  factory UnreadActivityModel.fromJson(Map<String, dynamic> json) =>
      UnreadActivityModel(
        activity: JsonMapper.integer(json['activity']),
        followRequests: JsonMapper.integer(json['follow_requests']),
      );

  @override
  List<Object?> get props => [activity, followRequests];
}
