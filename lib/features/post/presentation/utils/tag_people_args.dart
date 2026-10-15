import '../../../../core/utils/equatable.dart';
import 'tag_choice.dart';
import 'tag_photo.dart';

/// What the Tag people and Tag in photo pages open with: the people already chosen and the post's media.
class TagPeopleArgs extends Equatable {
  final List<TagChoice> chosen;
  final List<TagPhoto> photos;

  const TagPeopleArgs({required this.chosen, required this.photos});

  /// Tag in photo only has photos to work with; videos take no spot.
  bool get hasPhotos => photos.any((photo) => !photo.isVideo);

  @override
  List<Object?> get props => [chosen, photos];
}
