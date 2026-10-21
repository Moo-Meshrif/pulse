/// What happened to one item since the last check. [wire] is the `op` of `changes_since`.
enum ContentChangeOp {
  /// New or changed, and the signed-in user can see it.
  upsert('upsert'),

  /// Changed, and the signed-in user can no longer see it (e.g. it became Only me).
  remove('remove'),

  /// Deleted.
  delete('delete');

  const ContentChangeOp(this.wire);

  final String wire;

  static ContentChangeOp? fromWire(Object? wire) {
    for (final op in values) {
      if (op.wire == wire) return op;
    }
    return null;
  }
}
