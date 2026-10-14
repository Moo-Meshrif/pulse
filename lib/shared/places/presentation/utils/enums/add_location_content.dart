import '../../cubit/add_location_state.dart';
import 'location_search_status.dart';

/// What fills the screen under the header: one of the four panels of the board.
enum AddLocationContent {
  /// The permission is not known yet.
  loading,

  /// Panel 4: the permission primer.
  primer,

  /// Panel 2: results for what was typed, or the loader or the failure under it.
  search,

  /// Panel 3: the search found nothing.
  noResults,

  /// Panel 1: current location, nearby and recent.
  home;

  static AddLocationContent resolve(AddLocationState state) {
    if (state.isLoading) return loading;
    if (state.showPrimer) return primer;
    if (!state.isSearching) return home;
    final searchedNothing =
        state.searchStatus == LocationSearchStatus.ready &&
        state.results.isEmpty;
    return searchedNothing ? noResults : search;
  }
}
