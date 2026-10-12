import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/enums/signed_out_reason.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// "You've been signed out" with the reason (docs/specs/auth/02-components.md C17): a soft banner, not
/// dismissible, announced once when it appears.
class SessionBanner extends StatelessWidget {
  const SessionBanner({super.key, required this.reason});

  final SignedOutReason reason;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final body = switch (reason) {
      SignedOutReason.expired => l10n.signedOutExpiredBody,
      SignedOutReason.revoked => l10n.signedOutRevokedBody,
    };
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(AuthDimens.signedOutBannerPadding),
        decoration: BoxDecoration(
          color: colors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Padding(
                padding: EdgeInsets.only(
                  top: AuthDimens.signedOutBannerIconNudge,
                ),
                child: AppSvgIcon(
                  AppAssets.unlock,
                  size: AuthDimens.signedOutBannerIcon,
                  color: colors.primary,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.signedOutTitle,
                    style: context.text.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    color: colors.primary,
                  ),
                  SizedBox(height: AuthDimens.signedOutBannerTitleGap),
                  AppText(
                    body,
                    style: context.text.caption,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
