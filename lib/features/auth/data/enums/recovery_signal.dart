/// What the emailed password-reset link did when the app opened from it.
enum RecoverySignal {
  /// A recovery session started: the reset screen can show its form.
  started,

  /// The link was refused (expired or already used): no session; the reset screen shows its message.
  linkFailed,
}
