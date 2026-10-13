import 'main_tab.dart';

/// What system back does in the main shell.
enum ShellBackAction {
  /// A page is open inside the tab: close it.
  popTab,

  /// On the root of a tab other than Home: go to Home.
  goHome,

  /// On the Home root: leave the app (where the platform allows it).
  leaveApp;

  static ShellBackAction resolve({
    required MainTab selected,
    required bool tabCanPop,
  }) {
    if (tabCanPop) return popTab;
    if (selected != MainTab.home) return goHome;
    return leaveApp;
  }
}
