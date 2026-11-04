import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/comment_audience.dart';
import '../enums/message_audience.dart';

/// The caller's privacy choices on `profiles`. A column the server did not send has its default.
class PrivacySettingsModel extends Equatable {
  const PrivacySettingsModel({
    this.isPrivate = false,
    this.whoCanMessage = MessageAudience.everyone,
    this.whoCanComment = CommentAudience.everyone,
    this.showActivity = true,
    this.appearInSearch = true,
  });

  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) =>
      PrivacySettingsModel(
        isPrivate: JsonMapper.boolean(json['is_private']) ?? false,
        whoCanMessage: MessageAudience.fromJson(json['who_can_message']),
        whoCanComment: CommentAudience.fromJson(json['who_can_comment']),
        showActivity: JsonMapper.boolean(json['show_activity']) ?? true,
        appearInSearch: JsonMapper.boolean(json['appear_in_search']) ?? true,
      );

  final bool isPrivate;
  final MessageAudience whoCanMessage;
  final CommentAudience whoCanComment;
  final bool showActivity;
  final bool appearInSearch;

  PrivacySettingsModel copyWith({
    bool? isPrivate,
    MessageAudience? whoCanMessage,
    CommentAudience? whoCanComment,
    bool? showActivity,
    bool? appearInSearch,
  }) => PrivacySettingsModel(
    isPrivate: isPrivate ?? this.isPrivate,
    whoCanMessage: whoCanMessage ?? this.whoCanMessage,
    whoCanComment: whoCanComment ?? this.whoCanComment,
    showActivity: showActivity ?? this.showActivity,
    appearInSearch: appearInSearch ?? this.appearInSearch,
  );

  @override
  List<Object?> get props => [
    isPrivate,
    whoCanMessage,
    whoCanComment,
    showActivity,
    appearInSearch,
  ];
}
