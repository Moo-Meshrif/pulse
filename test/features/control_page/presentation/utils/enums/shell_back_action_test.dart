import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/control_page/presentation/utils/enums/main_tab.dart';
import 'package:pulse/features/control_page/presentation/utils/enums/shell_back_action.dart';

void main() {
  test('a page open inside the tab is closed first, on any tab', () {
    for (final tab in MainTab.values) {
      expect(
        ShellBackAction.resolve(selected: tab, tabCanPop: true),
        ShellBackAction.popTab,
      );
    }
  });

  test('on the root of a tab other than Home, back goes to Home', () {
    for (final tab in MainTab.values.where((t) => t != MainTab.home)) {
      expect(
        ShellBackAction.resolve(selected: tab, tabCanPop: false),
        ShellBackAction.goHome,
      );
    }
  });

  test('on the Home root, back leaves the app', () {
    expect(
      ShellBackAction.resolve(selected: MainTab.home, tabCanPop: false),
      ShellBackAction.leaveApp,
    );
  });
}
