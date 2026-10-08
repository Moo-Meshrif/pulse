import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../utils/bold_spans.dart';

/// Title + subtitle with an optional [leading] tile (docs/specs/auth/02-components.md C1). [emphasis] is
/// shown bold inside the subtitle.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.leading,
    required this.title,
    required this.subtitle,
    this.emphasis,
  });

  final Widget? leading;
  final String title;
  final String subtitle;

  /// A part of [subtitle] to set in bold.
  final String? emphasis;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base = context.text.subtitle.copyWith(color: colors.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          SizedBox(height: AuthDimens.tileToTitleGap),
        ],
        Semantics(
          header: true,
          child: AppText(
            title,
            style: context.text.display,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.s8),
        Text.rich(
          TextSpan(style: base, children: boldSpans(subtitle, emphasis, base)),
        ),
      ],
    );
  }
}
