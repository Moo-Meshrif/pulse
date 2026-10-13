/// The two tabs of a list screen. [wire] is `audience_people`'s `p_tab`.
enum AudienceTab {
  /// Everyone, the people who watch your stories most recently first.
  suggested('suggested'),

  /// Only the people on the list.
  selected('selected');

  const AudienceTab(this.wire);

  final String wire;
}
