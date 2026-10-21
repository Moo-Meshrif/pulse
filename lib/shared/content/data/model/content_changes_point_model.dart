import '../../../../core/utils/json_mapper.dart';

/// Where the last check stopped, kept on this device: the time and id of the last change seen, or the
/// time the server answered at when nothing was left.
class ContentChangesPointModel {
  const ContentChangesPointModel({this.at, this.id});

  final DateTime? at;
  final String? id;

  factory ContentChangesPointModel.fromJson(Map<String, dynamic> json) =>
      ContentChangesPointModel(
        at: JsonMapper.date(json['at']),
        id: JsonMapper.string(json['id']),
      );

  Map<String, dynamic> toJson() => {'at': at?.toIso8601String(), 'id': id};
}
