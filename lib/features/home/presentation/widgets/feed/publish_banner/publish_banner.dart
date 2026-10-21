import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/extensions/l10n.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../shared/content/domain/entity/content_publish_line.dart';
import '../../../cubit/post_publish/post_line_cubit.dart';
import '../../../cubit/post_publish/post_publish_cubit.dart';
import '../../../dimens/home_dimens.dart';
import 'publish_card_frame.dart';
import 'publish_line_card.dart';
import 'publish_thumb.dart';

/// The posts being shared or saved, above the feed: one post is a thumbnail and a line showing how
/// much is sent, or "couldn't post" with Retry and Discard; several posts are one card with the whole
/// line's progress that opens into one row per post. Discard hides a post at once; the server is told in
/// the background, also when offline. It is not there when nothing is going on.
class PublishBanner extends StatelessWidget {
  const PublishBanner({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PostLineCubit, ContentPublishLine>(
        builder: (context, line) {
          if (line.isEmpty) return const SizedBox.shrink();
          if (line.items.length > 1) return PublishLineCard(line: line);
          return _SingleCard(item: line.items.single);
        },
      );
}

class _SingleCard extends StatelessWidget {
  const _SingleCard({required this.item});

  final ContentLineItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final isFailed = item.state == ContentLineState.failed;
    if (item.state == ContentLineState.done) return const SizedBox.shrink();
    return PublishCardFrame(
      child: Row(
        children: [
          PublishThumb(item: item, size: HomeDimens.publishThumb),
          SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  _title(context),
                  style: context.text.name,
                  color: isFailed ? colors.danger : colors.textPrimary,
                ),
                if (!isFailed) ...[
                  SizedBox(height: AppSpacing.s8),
                  PublishBar(
                    // Moving until the first bytes go out, then how much is sent.
                    value: item.progress == 0 ? null : item.progress,
                  ),
                ],
              ],
            ),
          ),
          if (isFailed) ...[
            TextButton(
              onPressed: () =>
                  context.read<PostPublishCubit>().discard(item.id),
              child: Text(l10n.postPublishDiscard),
            ),
            if (item.canRetry)
              TextButton(
                onPressed: () =>
                    context.read<PostPublishCubit>().retry(item.id),
                child: Text(l10n.retry),
              ),
          ],
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    final l10n = context.l10n;
    if (item.state == ContentLineState.failed) {
      return item.isEdit ? l10n.editPostSaveFailed : l10n.postPublishFailed;
    }
    return item.isEdit ? l10n.postPublishSaving : l10n.postPublishing;
  }
}
