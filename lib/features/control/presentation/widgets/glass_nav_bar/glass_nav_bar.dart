import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../utils/enums/main_tab.dart';
import 'glass_border_painter.dart';
import 'nav_bubble.dart';
import 'nav_item.dart';
import 'outside_shadow_painter.dart';

/// The floating "liquid glass" bar of the main shell (docs/specs/control-page/screens/s0-glass-nav.md):
/// Home, Shorts, Create, Chat, Profile, no visible labels. It only draws and reports taps; the shell owns
/// the state and places the bar (bottom `NavDimens.bottomInset` + the system inset).
///
/// A tap on a tab always calls [onTabSelected], also on the selected one (the shell pops or scrolls to
/// top); only a change of tab, and Create, give a haptic tick.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.selected,
    required this.onTabSelected,
    required this.onCreate,
    this.chatBadge = 0,
  });

  final MainTab selected;
  final ValueChanged<MainTab> onTabSelected;
  final VoidCallback onCreate;

  /// Unread chats; 0 hides the badge.
  final int chatBadge;

  // Slots in order; null is the Create button.
  static const _slots = <MainTab?>[
    MainTab.home,
    MainTab.shorts,
    null,
    MainTab.chat,
    MainTab.profile,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = BorderRadius.circular(NavDimens.radius);
    // TODO(control-page-plan T9): the flat low-tier fill (`AppColors.glassFillFlat`) is not used; no device
    // detection yet (user decision).
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: NavDimens.sideInset),
      child: ContentWidth(
        child: SizedBox(
          height: NavDimens.height,
          child: CustomPaint(
            painter: OutsideShadowPainter(
              borderRadius: radius,
              shadows: AppShadows.navBar,
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: NavDimens.blurSigma,
                  sigmaY: NavDimens.blurSigma,
                ),
                child: CustomPaint(
                  foregroundPainter: GlassBorderPainter(
                    radius: NavDimens.radius,
                    colors: [
                      colors.glassHighlightTop,
                      colors.glassBorder,
                      colors.glassBorder,
                      colors.glassHighlightBottom,
                    ],
                    stops: const [0, 0.04, 0.96, 1],
                  ),
                  child: ColoredBox(
                    color: colors.glassFill,
                    child: Padding(
                      padding: EdgeInsets.all(NavDimens.padding),
                      child: _Slots(
                        selected: selected,
                        onTabSelected: _onTab,
                        onCreate: _onCreate,
                        chatBadge: chatBadge,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTab(MainTab tab) {
    if (tab != selected) HapticFeedback.selectionClick();
    onTabSelected(tab);
  }

  void _onCreate() {
    HapticFeedback.selectionClick();
    onCreate();
  }
}

class _Slots extends StatelessWidget {
  const _Slots({
    required this.selected,
    required this.onTabSelected,
    required this.onCreate,
    required this.chatBadge,
  });

  final MainTab selected;
  final ValueChanged<MainTab> onTabSelected;
  final VoidCallback onCreate;
  final int chatBadge;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final slots = GlassNavBar._slots;
    final selectedSlot = slots.indexOf(selected);
    return LayoutBuilder(
      builder: (context, constraints) {
        final gaps = NavDimens.itemGap * (slots.length - 1);
        final itemWidth = (constraints.maxWidth - gaps) / slots.length;
        final bubbleTop = (constraints.maxHeight - NavDimens.bubble) / 2;
        final bubbleStart =
            selectedSlot * (itemWidth + NavDimens.itemGap) +
            (itemWidth - NavDimens.bubble) / 2;
        return Stack(
          children: [
            AnimatedPositionedDirectional(
              duration: reduceMotion ? Duration.zero : NavDimens.bubbleDuration,
              curve: NavDimens.bubbleCurve,
              top: bubbleTop,
              start: bubbleStart,
              child: const NavBubble(),
            ),
            Row(
              children: [
                for (var i = 0; i < slots.length; i++) ...[
                  if (i > 0) SizedBox(width: NavDimens.itemGap),
                  Expanded(child: _slot(context, slots[i])),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _slot(BuildContext context, MainTab? tab) {
    if (tab == null) {
      return NavItem(
        icon: AppAssets.plus,
        activeIcon: AppAssets.plus,
        iconSize: NavDimens.plusIcon,
        label: context.l10n.navCreate,
        onTap: onCreate,
      );
    }
    return NavItem(
      icon: tab.icon,
      activeIcon: tab.activeIcon,
      iconSize: NavDimens.icon,
      label: tab.l10n(context),
      selected: tab == selected,
      onTap: () => onTabSelected(tab),
      badgeCount: tab == MainTab.chat ? chatBadge : 0,
      badgeLabel: tab == MainTab.chat
          ? context.l10n.navUnread(chatBadge)
          : null,
    );
  }
}
