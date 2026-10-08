import 'package:flutter/widgets.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../password_policy.dart';

/// How strong a password is, from [PasswordPolicy.score]: 1 Weak, 2 Fair, 3 Good, 4 Strong.
/// A score of 0 has no strength (the meter is hidden).
enum PasswordStrength {
  weak(segments: 1),
  fair(segments: 2),
  good(segments: 3),
  strong(segments: 4);

  const PasswordStrength({required this.segments});

  /// How many of the 4 meter segments are filled.
  final int segments;

  static PasswordStrength? of(String password) {
    final score = PasswordPolicy.score(password);
    return score == 0 ? null : values[score - 1];
  }

  String l10n(BuildContext context) => switch (this) {
    PasswordStrength.weak => context.l10n.strengthWeak,
    PasswordStrength.fair => context.l10n.strengthFair,
    PasswordStrength.good => context.l10n.strengthGood,
    PasswordStrength.strong => context.l10n.strengthStrong,
  };

  /// Weak `danger`, Fair `warning`, Good and Strong `primary`.
  Color color(BuildContext context) => switch (this) {
    PasswordStrength.weak => context.appColors.danger,
    PasswordStrength.fair => context.appColors.warning,
    PasswordStrength.good => context.appColors.primary,
    PasswordStrength.strong => context.appColors.primary,
  };
}
