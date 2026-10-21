import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/extensions/l10n.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../shared/content/domain/entity/content_publish_line.dart';
import '../../../dimens/home_dimens.dart';
import 'publish_card_frame.dart';
import 'publish_thumb.dart';

class PublishLineHeader extends StatelessWidget {
  const PublishLineHeader({
    super.key,
    required this.line,
    required this.title,
    required this.sub,
    required this.isOpen,
    required this.isOffline,
    required this.hasFailed,
    required this.onToggle,
  });

  final ContentPublishLine line;
  final String title;
  final String sub;
  final bool isOpen;
  final bool isOffline;
  final bool hasFailed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        _Stack(items: line.items),
        SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                style: context.text.name,
                color: colors.textPrimary,
              ),
              AppText(
                sub,
                style: context.text.caption,
                color: hasFailed ? colors.warningInk : colors.textSecondary,
              ),
              SizedBox(height: AppSpacing.s8),
              PublishBar(
                value: line.isAllDone || line.progress > 0
                    ? line.progress
                    : null,
                isPaused: isOffline,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: isOpen
              ? context.l10n.postPublishHideAll
              : context.l10n.postPublishShowAll,
          onPressed: onToggle,
          icon: AnimatedRotation(
            turns: isOpen ? 0.5 : 0,
            duration: HomeDimens.publishExpand,
            child: AppSvgIcon(
              AppAssets.chevronDown,
              size: HomeDimens.publishChevron,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Up to three pictures stacked, each a little to the side of the one in front.
class _Stack extends StatelessWidget {
  const _Stack({required this.items});

  final List<ContentLineItem> items;

  @override
  Widget build(BuildContext context) {
    final shown = items.take(HomeDimens.publishStackLayers).toList();
    final offset = HomeDimens.publishStackOffset;
    return SizedBox(
      width: HomeDimens.publishThumb + offset * (shown.length - 1),
      height: HomeDimens.publishThumb,
      child: Stack(
        children: [
          for (final (i, item) in shown.indexed.toList().reversed)
            PositionedDirectional(
              start: offset * i,
              child: PublishThumb(item: item, size: HomeDimens.publishThumb),
            ),
        ],
      ),
    );
  }
}
