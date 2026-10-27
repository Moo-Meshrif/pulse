import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import 'app_image.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';
import 'avatar_initials.dart';

/// A person in a list: avatar (photo or initials), name with an optional verified tick, a [subtitle]
/// line (@handle and meta) and a [trailing] widget such as an `OutlinePillButton`. A null [onTap] makes
/// the row static.
class PersonRow extends StatelessWidget {
  const PersonRow({
    super.key,
    required this.userId,
    required this.name,
    required this.subtitle,
    this.avatarUrl,
    this.isVerified = false,
    this.trailing,
    this.onTap,
  });

  final String userId;
  final String name;
  final String subtitle;
  final String? avatarUrl;
  final bool isVerified;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = SettingsDimens.personAvatar;
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: SettingsDimens.rowMinHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SettingsDimens.rowSide,
          vertical: AppSpacing.s8,
        ),
        child: Row(
          children: [
            ClipOval(
              child: avatarUrl == null
                  ? AvatarInitials(name: name, seed: userId, size: size)
                  : AppImage.network(
                      avatarUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      cacheWidth: size.round() * 2,
                      errorBuilder: (_) =>
                          AvatarInitials(name: name, seed: userId, size: size),
                    ),
            ),
            SizedBox(width: SettingsDimens.personGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: AppText(
                          name,
                          style: context.text.name,
                          maxLines: 1,
                        ),
                      ),
                      if (isVerified) ...[
                        SizedBox(width: AppSpacing.s4),
                        AppSvgIcon(
                          AppAssets.verified,
                          size: SettingsDimens.personVerified,
                          color: colors.primary,
                        ),
                      ],
                    ],
                  ),
                  AppText(
                    subtitle,
                    style: context.text.bodySm,
                    color: colors.textSecondary,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: SettingsDimens.rowGap),
              trailing!,
            ],
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.settingsTile),
      child: row,
    );
  }
}
