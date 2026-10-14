/// What kind of content an action is about. [wire] is the `p_kind` value of the shared RPCs.
enum ContentKind {
  post('post'),
  story('story'),
  short('short');

  const ContentKind(this.wire);

  final String wire;
}
