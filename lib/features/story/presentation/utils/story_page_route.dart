import 'package:flutter/material.dart';

import '../../../../core/theme/dimens/app_dimens.dart';
import '../dimens/story_constants.dart';

/// How the story viewer opens and closes (docs/specs/story/source-tokens.md §8): it grows out of the place
/// that was tapped (the rail avatar) while it fades in, and shrinks back into it on close, like the
/// stories of Facebook and Instagram, instead of sliding in like an ordinary page. [origin] is that place
/// in screen coordinates; without it the viewer grows from the centre. With reduced motion it only fades
/// (150 ms).
class StoryPageRoute<T> extends PageRoute<T> {
  StoryPageRoute({super.settings, required this.builder, this.origin})
    : super(fullscreenDialog: true);

  final WidgetBuilder builder;
  final Offset? origin;

  /// The start size of the grow.
  static const double _startScale = 0.1;

  @override
  Duration get transitionDuration => StoryMotion.heroOpen;

  @override
  Duration get reverseTransitionDuration => SheetMotion.exit;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.linear),
        child: child,
      );
    }
    final size = MediaQuery.sizeOf(context);
    final at = origin;
    final alignment = at == null || size.isEmpty
        ? Alignment.center
        : Alignment(
            (at.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
            (at.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
          );
    final curved = CurvedAnimation(
      parent: animation,
      curve: SheetMotion.curve,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      // The fade runs ahead of the grow, so the black screen does not sit on Home as a small square.
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0, 0.6),
        reverseCurve: const Interval(0.3, 1),
      ),
      child: ScaleTransition(
        scale: Tween(
          begin: _startScale,
          end: 1.0, // unscaled: animation scale, not a layout size
        ).animate(curved),
        alignment: alignment,
        child: child,
      ),
    );
  }
}
