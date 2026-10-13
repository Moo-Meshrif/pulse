import 'package:flutter/material.dart';

/// What the shell keeps per tab: its Navigator and the scroll controller of the tab's root page, and the
/// moves the shell makes on them (back, re-tap).
class TabHandle {
  static const _scrollToTopDuration = Duration(milliseconds: 300);

  final navigatorKey = GlobalKey<NavigatorState>();

  /// The primary scroll controller of the root page; null until the page is built.
  ScrollController? rootScroll;

  NavigatorState? get _navigator => navigatorKey.currentState;

  /// A page is open on top of the tab's root.
  bool get canPop => _navigator?.canPop() ?? false;

  void pop() => _navigator?.pop();

  /// Pops back to the root page. False when the tab was there already.
  bool popToRoot() {
    if (!canPop) return false;
    _navigator!.popUntil((route) => route.isFirst);
    return true;
  }

  /// Scrolls the root page to the top; nothing when it has no scroll view.
  void scrollToTop() {
    final scroll = rootScroll;
    if (scroll == null || !scroll.hasClients) return;
    scroll.animateTo(0, duration: _scrollToTopDuration, curve: Curves.easeOut);
  }
}
