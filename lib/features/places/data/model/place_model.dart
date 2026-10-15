import 'dart:convert';

import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/place_kind.dart';

/// A place from the `places` function, and the copy kept on the device for "recent".
class PlaceModel extends Equatable {
  final String? name;

  /// Area and city (or country), already worded by the function.
  final String? subtitle;
  final PlaceKind? kind;

  /// Kilometres from the position the search or nearby request gave.
  final double? distanceKm;

  const PlaceModel({this.name, this.subtitle, this.kind, this.distanceKm});

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
    name: JsonMapper.string(json['name']),
    subtitle: JsonMapper.string(json['subtitle']),
    kind: PlaceKind.fromWire(JsonMapper.string(json['kind'])),
    distanceKm: JsonMapper.decimal(json['distanceKm']),
  );

  /// The copy kept for "recent": no distance, it belonged to another position.
  Map<String, dynamic> toJson() => {
    'name': name,
    'subtitle': subtitle,
    'kind': kind?.wire,
  };

  static PlaceModel? fromStored(String raw) {
    try {
      final json = jsonDecode(raw);
      return json is Map<String, dynamic> ? PlaceModel.fromJson(json) : null;
    } on FormatException {
      return null;
    }
  }

  String toStored() => jsonEncode(toJson());

  @override
  List<Object?> get props => [name, subtitle, kind, distanceKm];
}
