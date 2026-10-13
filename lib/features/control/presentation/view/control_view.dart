import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_navigator.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/control_cubit.dart';
import '../cubit/control_state.dart';
import '../utils/enums/main_tab.dart';
import '../utils/enums/shell_back_action.dart';
import '../utils/tab_handle.dart';
import '../widgets/create_sheet/create_sheet.dart';
import '../widgets/glass_nav_bar/glass_nav_bar.dart';
import '../widgets/tab_navigator.dart';

/// The main shell (docs/specs/control-page/screens/s0-glass-nav.md): the four tabs, each in its own
/// Navigator, and the floating glass nav bar over them. [rootBuilder] gives each tab's root page.
///
/// The view owns what needs the tabs' Navigators: system back and a re-tap on the selected tab. Which tab
/// is selected lives in [ControlCubit].
class ControlView extends StatefulWidget {
  const ControlView({super.key, required this.rootBuilder});

  final Widget Function(BuildContext context, MainTab tab) rootBuilder;

  @override
  State<ControlView> createState() => _ControlViewState();
}

class _ControlViewState extends State<ControlView> {
  final _handles = {for (final tab in MainTab.values) tab: TabHandle()};

  ControlCubit get _cubit => context.read<ControlCubit>();

  void _onBack() {
    final selected = _cubit.state.selected;
    final handle = _handles[selected]!;
    switch (ShellBackAction.resolve(
      selected: selected,
      tabCanPop: handle.canPop,
    )) {
      case ShellBackAction.popTab:
        handle.pop();
      case ShellBackAction.goHome:
        _cubit.goHome();
      case ShellBackAction.leaveApp:
        if (defaultTargetPlatform == TargetPlatform.android) {
          SystemNavigator.pop();
        }
    }
  }

  /// Another tab: switch to it. The selected tab again: go back to its root, or when it is there
  /// already, scroll it to the top.
  void _onTab(MainTab tab) {
    if (tab != _cubit.state.selected) {
      _cubit.select(tab);
      return;
    }
    final handle = _handles[tab]!;
    if (handle.popToRoot()) return;
    // TODO(control-page-plan T6): on the Home root also refresh the feed once the home feature exists.
    handle.scrollToTop();
  }

  /// Closes the sheet and opens the chosen flow over the whole shell, nav bar included.
  Future<void> _onCreate() async {
    final option = await CreateSheet.show(context);
    if (option == null || !mounted) return;
    AppNavigator.push<void>(context, option.route, rootNavigator: true);
  }

  @override
  Widget build(BuildContext context) {
    final systemInset = MediaQuery.viewPaddingOf(context).bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Tells the tabs' pages how much room the bar takes at the bottom.
            NavClearance(
              bottom: NavDimens.contentClearance + systemInset,
              child: _TabStack(
                handles: _handles,
                rootBuilder: widget.rootBuilder,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: NavDimens.bottomInset + systemInset,
              child: _NavBar(onTab: _onTab, onCreate: _onCreate),
            ),
          ],
        ),
      ),
    );
  }
}

/// The four tabs on top of each other, showing the selected one. A tab is built the first time it is
/// selected and then kept, so it keeps its state and scroll position.
class _TabStack extends StatefulWidget {
  const _TabStack({required this.handles, required this.rootBuilder});

  final Map<MainTab, TabHandle> handles;
  final Widget Function(BuildContext context, MainTab tab) rootBuilder;

  @override
  State<_TabStack> createState() => _TabStackState();
}

class _TabStackState extends State<_TabStack> {
  /// The tabs opened so far; Home is the first.
  final _opened = {MainTab.home};

  @override
  Widget build(BuildContext context) =>
      BlocSelector<ControlCubit, ControlState, MainTab>(
        selector: (state) => state.selected,
        builder: (context, selected) {
          _opened.add(selected);
          return IndexedStack(
            index: selected.index,
            children: [for (final tab in MainTab.values) _tab(tab)],
          );
        },
      );

  Widget _tab(MainTab tab) {
    if (!_opened.contains(tab)) return const SizedBox.shrink();
    return TabNavigator(
      handle: widget.handles[tab]!,
      root: (context) => widget.rootBuilder(context, tab),
    );
  }
}

/// The nav bar, hidden under the keyboard (slides down in 200 ms; instant with reduce motion).
class _NavBar extends StatelessWidget {
  const _NavBar({required this.onTab, required this.onCreate});

  final ValueChanged<MainTab> onTab;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final hidden = MediaQuery.viewInsetsOf(context).bottom > 0;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedSlide(
      offset: hidden ? const Offset(0, 2) : Offset.zero,
      duration: reduceMotion ? Duration.zero : NavDimens.hideDuration,
      curve: Curves.easeOut,
      child: IgnorePointer(
        ignoring: hidden,
        child: ExcludeSemantics(
          excluding: hidden,
          child: BlocBuilder<ControlCubit, ControlState>(
            buildWhen: (a, b) =>
                a.selected != b.selected || a.chatUnread != b.chatUnread,
            builder: (context, state) => GlassNavBar(
              selected: state.selected,
              chatBadge: state.chatUnread,
              onTabSelected: onTab,
              onCreate: onCreate,
            ),
          ),
        ),
      ),
    );
  }
}
