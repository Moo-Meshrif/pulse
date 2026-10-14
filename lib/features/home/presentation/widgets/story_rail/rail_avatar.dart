import 'package:flutter/material.dart';

import '../../../../../core/widgets/widgets.dart';
import '../../../../story/domain/entity/story_rail_item_entity.dart';

/// A person's photo on the rail, or their initials without one.
class RailAvatar extends StatelessWidget {
  const RailAvatar({super.key, required this.person, required this.size});

  final StoryRailItemEntity person;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = person.avatarUrl;
    final initials = AvatarInitials(
      name: person.fullName ?? person.username,
      seed: person.authorId,
      size: size,
    );
    return ClipOval(
      child: url == null
          ? initials
          : AppImage.network(
              url,
              width: size,
              height: size,
              cacheWidth: (size * 2).round(),
              errorBuilder: (_) => initials,
            ),
    );
  }
}
