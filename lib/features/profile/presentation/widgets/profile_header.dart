import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/model/profile_page_model.dart';
import '../dimens/profile_dimens.dart';

/// A profile's top: the cover with a round button at each side, the photo over it, the name, @name, bio
/// and place. [leading] and [trailing] are the cover buttons; [onAvatarTap] opens the photo (null: nothing).
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.page,
    required this.leading,
    required this.trailing,
    this.onAvatarTap,
  });

  final ProfilePageModel page;
  final Widget leading;
  final Widget trailing;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final top = MediaQuery.paddingOf(context).top;
    final coverHeight = ProfileDimens.coverHeight + top;
    final bio = page.bio ?? '';
    final city = page.city ?? '';
    final avatarOuter =
        ProfileDimens.avatar +
        2 * (ProfileDimens.avatarWhiteRing + ProfileDimens.avatarRing);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: coverHeight + avatarOuter - ProfileDimens.avatarOverlap,
          child: Stack(
            children: [
              PositionedDirectional(
                top: 0,
                start: 0,
                end: 0,
                height: coverHeight,
                child: _Cover(url: page.coverUrl),
              ),
              PositionedDirectional(
                top: top + ProfileDimens.coverButtonTop,
                start: ProfileDimens.coverButtonSide,
                child: leading,
              ),
              PositionedDirectional(
                top: top + ProfileDimens.coverButtonTop,
                end: ProfileDimens.coverButtonSide,
                child: trailing,
              ),
              PositionedDirectional(
                top: coverHeight - ProfileDimens.avatarOverlap,
                start: AppSpacing.s16,
                child: _Avatar(page: page, onTap: onAvatarTap),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s16,
            AppSpacing.s16,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: AppText(
                      page.fullName ?? '',
                      style: context.text.title,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (page.isVerified ?? false) ...[
                    SizedBox(width: AppSpacing.s8),
                    AppSvgIcon(
                      AppAssets.verified,
                      size: ProfileDimens.verifiedIcon,
                      color: colors.primary,
                    ),
                  ],
                ],
              ),
              SizedBox(height: ProfileDimens.headerGap),
              AppText(
                '@${page.username ?? ''}',
                style: context.text.bodySm,
                color: colors.textSecondary,
              ),
              if (bio.isNotEmpty) ...[
                SizedBox(height: AppSpacing.s8),
                AppText(
                  bio,
                  style: context.text.body,
                  color: colors.textPrimary,
                  maxLines: 3,
                ),
              ],
              if (city.isNotEmpty) ...[
                SizedBox(height: AppSpacing.s8),
                Row(
                  children: [
                    AppSvgIcon(
                      AppAssets.location,
                      size: ProfileDimens.locationIcon,
                      color: colors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.s4),
                    Flexible(
                      child: AppText(
                        city,
                        style: context.text.bodySm,
                        color: colors.textSecondary,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The person's cover, or the default one.
class _Cover extends StatelessWidget {
  const _Cover({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const fallback = AppImage.asset(AppAssets.profileCover, fit: BoxFit.cover);
    final url = this.url;
    if (url == null) return fallback;
    return AppImage.network(
      url,
      fit: BoxFit.cover,
      cacheWidth: 1200,
      errorBuilder: (_) => fallback,
    );
  }
}

/// The photo (or initials) inside a white ring and a primary ring.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.page, required this.onTap});

  final ProfilePageModel page;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final url = page.avatarUrl;
    final size = ProfileDimens.avatar;
    final initials = AvatarInitials(
      name: page.fullName,
      seed: page.id,
      size: size,
      fontSize: ProfileDimens.avatarInitials,
    );
    return Semantics(
      button: onTap != null,
      label: onTap == null ? null : context.l10n.profileViewPhotoA11y,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(ProfileDimens.avatarWhiteRing),
          decoration: BoxDecoration(
            color: colors.surface,
            shape: BoxShape.circle,
          ),
          child: Container(
            padding: const EdgeInsets.all(ProfileDimens.avatarRing),
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: url == null
                  ? initials
                  : AppImage.network(
                      url,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      cacheWidth: size.round() * 2,
                      errorBuilder: (_) => initials,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
