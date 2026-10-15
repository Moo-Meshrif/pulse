import '../../../../core/utils/equatable.dart';

/// What the tagged people sheet asks for when it closes: a profile to open, or removing your own tag.
class TaggedPeopleResult extends Equatable {
  final String? profileId;
  final bool removeMe;

  const TaggedPeopleResult.profile(String this.profileId) : removeMe = false;
  const TaggedPeopleResult.removeMe() : profileId = null, removeMe = true;

  @override
  List<Object?> get props => [profileId, removeMe];
}
