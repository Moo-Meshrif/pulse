/// Where a post, short or story that is not posted yet is on the server. [wire] is the
/// `pending_content.state` value.
enum PendingContentState {
  draft('draft'),
  waiting('waiting'),
  published('published'),
  rejected('rejected'),
  discarded('discarded'),
  abandoned('abandoned');

  const PendingContentState(this.wire);

  final String wire;

  static PendingContentState? fromWire(Object? wire) {
    for (final state in values) {
      if (state.wire == wire) return state;
    }
    return null;
  }
}
