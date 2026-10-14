import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// The row of `audience_summary()`: how many followers, close friends and hidden people you have.
class AudienceSummaryModel extends Equatable {
  final int? followers;
  final int? closeFriends;
  final int? hidden;

  const AudienceSummaryModel({this.followers, this.closeFriends, this.hidden});

  factory AudienceSummaryModel.fromJson(Map<String, dynamic> json) =>
      AudienceSummaryModel(
        followers: JsonMapper.integer(json['followers']),
        closeFriends: JsonMapper.integer(json['close_friends']),
        hidden: JsonMapper.integer(json['hidden']),
      );

  @override
  List<Object?> get props => [followers, closeFriends, hidden];
}
