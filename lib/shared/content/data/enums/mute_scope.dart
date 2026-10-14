/// What muting a person hides. Posts and stories are muted on their own. [wire] is the `p_scope` value
/// of `set_mute`.
enum MuteScope {
  posts('posts'),
  stories('stories');

  const MuteScope(this.wire);

  final String wire;
}
