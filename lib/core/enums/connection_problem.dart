/// Why a request failed on the connection, found by checking the connection after the failure
/// (`ConnectivityService.diagnose`). Screens map it to their own copy.
enum ConnectionProblem {
  /// No Wi-Fi and no mobile data.
  offline,

  /// A network is on, but it reaches nothing.
  noInternet,

  /// The backend answers too slowly.
  weak,

  /// The connection is fine: the failure is on our side.
  cantReach,
}
