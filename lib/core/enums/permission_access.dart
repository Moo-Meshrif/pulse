/// Where one device permission stands, as the camera flows need it.
enum PermissionAccess {
  granted,

  /// Refused or never asked, and the system will still show its prompt.
  denied,

  /// Refused for good: only Settings can turn it on.
  blocked,

  /// Parental controls or a device policy: not even Settings can turn it on.
  restricted,
}
