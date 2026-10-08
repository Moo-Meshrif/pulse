import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';

/// A scrolling [body] above a pinned call-to-action (docs/specs/auth/02-components.md C15). A Column, so
/// the area rises above the keyboard and the body scrolls.
class PinnedBottomCta extends StatelessWidget {
  const PinnedBottomCta({
    super.key,
    required this.body,
    required this.cta,
    this.showTopDivider = false,
  });

  final Widget body;

  /// The button, plus any caption or link under it.
  final Widget cta;
  final bool showTopDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        Expanded(child: body),
        DecoratedBox(
          decoration: BoxDecoration(
            color: showTopDivider ? colors.surface : null,
            border: showTopDivider
                ? Border(
                    top: BorderSide(
                      color: colors.divider,
                      width: AuthDimens.dividerLineWidth,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.formSide,
              showTopDivider ? AppSpacing.s12 : 0,
              AppSpacing.formSide,
              AppSpacing.s24,
            ),
            child: cta,
          ),
        ),
      ],
    );
  }
}
