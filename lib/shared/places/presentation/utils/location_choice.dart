import '../../../../core/utils/equatable.dart';

/// What Add location hands back to New post: the place name to save, or none ("Remove").
class LocationChoice extends Equatable {
  /// Null removes the location from the post.
  final String? name;

  const LocationChoice(this.name);

  @override
  List<Object?> get props => [name];
}
