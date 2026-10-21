import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';
import '../../../../story/domain/entity/story_rail_item_entity.dart';
import '../../dimens/home_dimens.dart';
import 'rail_avatar.dart';
import 'rail_rings.dart';

/// Your photo or initials (an empty soft circle only when the account is not known) inside a ring drawn [progress] of the way.
class RingedPhoto extends StatelessWidget {
  const RingedPhoto({
    super.key,
    required this.me,
    this.account,
    required this.progress,
    required this.color,
    this.track,
  });

  final StoryRailItemEntity? me;

  /// Who to show before there is a story of yours on the rail; an empty soft circle when null too.
  final LastAccountEntity? account;
  final double progress;
  final Color color;
  final Color? track;

  @override
  Widget build(BuildContext context) {
    final inset = StoryRailDimens.uploadRing + StoryRailDimens.railRingGap;
    final photo = StoryRailDimens.railAvatar - 2 * inset;
    final person = me;
    return CustomPaint(
      painter: ProgressRingPainter(
        progress: progress,
        color: color,
        track: track,
        width: StoryRailDimens.uploadRing,
      ),
      child: SizedBox.square(
        dimension: StoryRailDimens.railAvatar,
        child: Padding(
          padding: EdgeInsets.all(inset),
          child: Opacity(
            opacity: StoryRailDimens.uploadPhotoOpacity,
            child: switch ((person, account)) {
              (final person?, _) => RailAvatar(person: person, size: photo),
              (_, final account?) => _AccountAvatar(
                account: account,
                size: photo,
              ),
              _ => DecoratedBox(
                decoration: BoxDecoration(
                  color: context.appColors.primarySoft,
                  shape: BoxShape.circle,
                ),
              ),
            },
          ),
        ),
      ),
    );
  }
}

/// Your saved photo, or your initials without one.
class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.account, required this.size});

  final LastAccountEntity account;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = account.avatarUrl;
    final initials = AvatarInitials(
      name: account.fullName ?? account.username,
      seed: account.id,
      size: size,
    );
    return ClipOval(
      child: url == null
          ? initials
          : AppImage.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: (size * 2).round(),
              errorBuilder: (_) => initials,
            ),
    );
  }
}
