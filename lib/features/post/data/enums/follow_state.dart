/// How the signed-in user stands with a tagged person. [wire] is the `follow_state` of
/// `post_tagged_people`; [me] is the signed-in user.
enum FollowState {
  none('none'),
  pending('pending'),
  following('following'),
  me('me');

  const FollowState(this.wire);

  final String wire;

  static FollowState? fromWire(String? wire) {
    for (final state in values) {
      if (state.wire == wire) return state;
    }
    return null;
  }
}
