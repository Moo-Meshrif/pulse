import 'package:flutter/material.dart';

/// A tappable area with the button semantics every control on a post shares: [label] is what a screen
/// reader says, the visible children are hidden from it.
class PostTapButton extends StatelessWidget {
  const PostTapButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.value,
    this.isContainer = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget child;
  final String? value;
  final bool isContainer;

  @override
  Widget build(BuildContext context) => Semantics(
    container: isContainer,
    button: true,
    label: label,
    value: value,
    excludeSemantics: true,
    onTap: onTap,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    ),
  );
}
