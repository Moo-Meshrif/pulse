import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/content_audience.dart';

/// The two `profiles` columns the post audience depends on.
class PrivacyModel extends Equatable {
  final bool? isPrivate;
  final ContentAudience? defaultAudience;

  const PrivacyModel({this.isPrivate, this.defaultAudience});

  factory PrivacyModel.fromJson(Map<String, dynamic> json) => PrivacyModel(
    isPrivate: JsonMapper.boolean(json['is_private']),
    defaultAudience: ContentAudience.fromWire(json['default_post_visibility']),
  );

  @override
  List<Object?> get props => [isPrivate, defaultAudience];
}
