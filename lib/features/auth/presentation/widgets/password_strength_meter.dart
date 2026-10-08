import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../utils/enums/password_strength.dart';

/// The password strength meter (docs/specs/auth/02-components.md C8), hidden until the password scores.
/// [compact] is the reset screen's variant: always shown, no word.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({
    super.key,
    required this.password,
    this.compact = false,
  });

  final String password;
  final bool compact;

  static const _segmentCount = 4;

  @override
  Widget build(BuildContext context) {
    final strength = PasswordStrength.of(password);
    if (strength == null && !compact) return const SizedBox.shrink();
    final colors = context.appColors;

    Widget segment(int index) => AnimatedContainer(
      duration: AuthDimens.progressDuration,
      curve: Curves.easeInOut,
      height: AuthDimens.strengthSegmentHeight,
      width: compact ? AuthDimens.strengthShortSegmentWidth : null,
      decoration: BoxDecoration(
        color: strength != null && index < strength.segments
            ? strength.color(context)
            : colors.switchOff,
        borderRadius: BorderRadius.circular(
          AppRadius.pill(AuthDimens.strengthSegmentHeight),
        ),
      ),
    );

    final gap = compact
        ? AuthDimens.strengthShortSegmentGap
        : AuthDimens.strengthSegmentGap;
    final segments = Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      spacing: gap,
      children: [
        for (var i = 0; i < _segmentCount; i++)
          compact ? segment(i) : Expanded(child: segment(i)),
      ],
    );

    return Semantics(
      excludeSemantics: true,
      label: strength == null
          ? null
          : context.l10n.passwordStrength(strength.l10n(context)),
      child: compact || strength == null
          ? segments
          : Row(
              children: [
                Expanded(child: segments),
                SizedBox(width: AppSpacing.s12),
                AppText(
                  strength.l10n(context),
                  style: context.text.label,
                  color: colors.textSecondary,
                ),
              ],
            ),
    );
  }
}
