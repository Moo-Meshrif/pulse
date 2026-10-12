import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/snack_bar_context.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

// TODO(auth-plan, out of scope for now): real Google / Apple sign-in through Supabase OAuth (keys and
// redirect URIs are needed first); until then both buttons show "Coming soon".
/// Google and Apple, two equal outline pills (gap 12, text only). Real sign-in comes later: a tap shows
/// the "Coming soon" snackbar (docs/specs/auth/02-components.md C5).
class SocialButtonsRow extends StatelessWidget {
  const SocialButtonsRow({super.key});

  @override
  Widget build(BuildContext context) => Row(
    spacing: AuthDimens.socialGap,
    children: [
      Expanded(
        child: PillButton.outline(
          label: context.l10n.google,
          onPressed: () => context.showSnackBar(context.l10n.comingSoon),
        ),
      ),
      Expanded(
        child: PillButton.outline(
          label: context.l10n.apple,
          onPressed: () => context.showSnackBar(context.l10n.comingSoon),
        ),
      ),
    ],
  );
}
