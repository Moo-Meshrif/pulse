import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

class OtherProfileCard extends StatelessWidget {
  const OtherProfileCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });
  final String icon, title, body;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        AppSvgIcon(icon, size: 48, color: context.appColors.textSecondary),
        const SizedBox(height: 16),
        AppText(
          title,
          style: context.text.titleSm,
          color: context.appColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        AppText(
          body,
          style: context.text.bodySm,
          color: context.appColors.textSecondary,
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}

class FollowedByRow extends StatelessWidget {
  const FollowedByRow({super.key, required this.data, required this.onTap});
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final avatars = (data['avatars'] as List<dynamic>?) ?? const [];
    final first =
        data['first_full_name'] as String? ??
        data['first_username'] as String? ??
        '';
    final second =
        data['second_full_name'] as String? ??
        data['second_username'] as String?;
    final names = second == null ? first : '$first, $second';
    final rest =
        ((data['total'] as num?)?.toInt() ?? 0) - (second == null ? 1 : 2);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            for (final entry in avatars)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 2),
                child: CircleAvatar(
                  radius: 11,
                  backgroundImage: (entry as Map)['avatar_url'] == null
                      ? null
                      : NetworkImage(entry['avatar_url'] as String),
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: AppText(
                rest > 0
                    ? context.l10n.otherFollowedByMore(names, rest)
                    : context.l10n.otherFollowedBy(names),
                style: context.text.bodyXs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
