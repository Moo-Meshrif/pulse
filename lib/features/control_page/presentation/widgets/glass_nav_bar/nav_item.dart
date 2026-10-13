import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import 'nav_badge.dart';

/// One slot of the nav bar: an icon (the filled variant while selected) with no label, pressed = 90%
/// opacity, no ripple. The whole slot is the tap target. Used for the four tabs and for Create (which is
/// never selected).
class NavItem extends StatefulWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.iconSize,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.badgeCount = 0,
    this.badgeLabel,
  });

  final String icon;
  final String activeIcon;
  final double iconSize;

  /// Screen-reader label.
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final int badgeCount;

  /// Announced with the label when there is a badge (e.g. "4 unread").
  final String? badgeLabel;

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final asset = widget.selected ? widget.activeIcon : widget.icon;
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      value: widget.badgeCount > 0 ? widget.badgeLabel : null,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: Opacity(
          opacity: _pressed ? NavDimens.pressedOpacity : 1,
          child: SizedBox(
            height: NavDimens.itemHeight,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : NavDimens.iconFadeDuration,
                    child: AppSvgIcon(
                      asset,
                      key: ValueKey(asset),
                      size: widget.iconSize,
                      color: widget.selected
                          ? colors.primary
                          : colors.iconInactive,
                    ),
                  ),
                  PositionedDirectional(
                    top: NavDimens.badgeTop,
                    start:
                        constraints.maxWidth / 2 + NavDimens.badgeCenterOffset,
                    child: NavBadge(count: widget.badgeCount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
