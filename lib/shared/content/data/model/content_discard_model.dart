import '../../../../core/utils/json_mapper.dart';
import '../enums/content_kind.dart';

/// A discard saved on this device that the server has not confirmed yet.
class ContentDiscardModel {
  const ContentDiscardModel({this.id, this.kind});

  final String? id;
  final ContentKind? kind;

  factory ContentDiscardModel.fromJson(Map<String, dynamic> json) =>
      ContentDiscardModel(
        id: JsonMapper.string(json['id']),
        kind: ContentKind.fromWire(json['kind']),
      );

  Map<String, dynamic> toJson() => {'id': id, 'kind': kind?.wire};
}
