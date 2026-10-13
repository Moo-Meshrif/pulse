/// The two private lists of your followers behind "Who can see this".
enum AudienceList {
  /// Only these people see a Close friends story.
  closeFriends('close_friends'),

  /// These people see none of your stories.
  hiddenFrom('hidden');

  const AudienceList(this.wire);

  final String wire;
}
