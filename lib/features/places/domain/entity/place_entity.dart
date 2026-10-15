import '../../../../core/utils/equatable.dart';
import '../../data/enums/place_kind.dart';

/// A place the person can attach to what they share (a post, a story).
class PlaceEntity extends Equatable {
  /// What a `location` column may hold (`posts.location` is text, at most 80).
  static const maxDisplayNameLength = 80;

  final String name;

  /// Area and city (or country); empty when the function gave none.
  final String subtitle;
  final PlaceKind kind;

  /// Kilometres from where the person is, when the list knows.
  final double? distanceKm;

  const PlaceEntity({
    required this.name,
    this.subtitle = '',
    this.kind = PlaceKind.poi,
    this.distanceKm,
  });

  /// What is saved with the content: the name and its first subtitle part ("Zamalek, Cairo"), never GPS.
  String get displayName {
    final area = subtitle.split(', ').first;
    final text = area.isEmpty ? name : '$name, $area';
    return text.length <= maxDisplayNameLength
        ? text
        : text.substring(0, maxDisplayNameLength);
  }

  @override
  List<Object?> get props => [name, subtitle, kind, distanceKm];
}
