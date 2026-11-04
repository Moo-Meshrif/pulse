/// Whether the typed username can be used, as the Username field shows it.
enum UsernameStatus {
  /// Unchanged, empty or not checked yet.
  idle,
  checking,
  free,
  taken,
}
