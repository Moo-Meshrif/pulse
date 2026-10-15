import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../dimens/auth_dimens.dart';

/// The account Sign in is for after its session ended (docs/specs/auth/02-components.md C18): label,
/// then a card with the avatar, name, @username and "Not you?". [onNotYou] is null while busy.
class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.id,
    required this.fullName,
    required this.username,
    this.avatarUrl,
    required this.onNotYou,
  });

  final String id;
  final String? fullName;
  final String username;
  final String? avatarUrl;
  final VoidCallback? onNotYou;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final name = (fullName ?? '').trim().isEmpty ? username : fullName!.trim();
    final size = AuthDimens.accountAvatar;
    final initials = AvatarInitials(name: name, seed: id, size: size);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.accountLabel,
          style: context.text.label,
          color: colors.textPrimary,
        ),
        SizedBox(height: AppSpacing.labelGap),
        Container(
          constraints: BoxConstraints(minHeight: AuthDimens.accountCardHeight),
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.s12,
            end: AppSpacing.s12,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: size,
                height: size,
                child: avatarUrl == null
                    ? initials
                    : ClipOval(
                        child: AppImage.network(
                          avatarUrl!,
                          cacheWidth: (size * 2).round(),
                          errorBuilder: (_) => initials,
                        ),
                      ),
              ),
              SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Semantics(
                  container: true,
                  label: '${l10n.accountLabel}, $name, @$username',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        name,
                        style: context.text.name,
                        color: colors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: AppText(
                          '@$username',
                          style: context.text.caption,
                          color: colors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: onNotYou,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AuthDimens.linkTapHeight,
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: AppSpacing.s12,
                      ),
                      child: Semantics(
                        button: true,
                        child: AppText(
                          l10n.notYou,
                          style: context.text.bodySm.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          color: onNotYou == null
                              ? colors.textSecondary
                              : colors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
