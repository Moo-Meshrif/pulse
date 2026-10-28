import '../../../../core/utils/json_mapper.dart';

/// The values shown beside the Settings rows: whether the account is private, how many accounts are
/// blocked and whether push is on. Every field is null when the server did not send it.
class SettingsSummaryModel {
  const SettingsSummaryModel({
    this.isPrivate,
    this.blockedCount,
    this.pushEnabled,
  });

  factory SettingsSummaryModel.fromJson(Map<String, dynamic> json) =>
      SettingsSummaryModel(
        isPrivate: JsonMapper.boolean(json['is_private']),
        blockedCount: JsonMapper.integer(json['blocked_count']),
        pushEnabled: JsonMapper.boolean(json['push_enabled']),
      );

  final bool? isPrivate;
  final int? blockedCount;
  final bool? pushEnabled;
}
