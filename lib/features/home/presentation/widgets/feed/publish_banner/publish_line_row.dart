import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/extensions/l10n.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../shared/content/domain/entity/content_publish_line.dart';
import '../../../cubit/post_publish/post_publish_cubit.dart';
import '../../../dimens/home_dimens.dart';
import 'publish_card_frame.dart';
import 'publish_thumb.dart';

class PublishLineRow extends StatelessWidget {
  const PublishLineRow({super.key, required this.item, required this.number});

  final ContentLineItem item;
  final int number;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(top: HomeDimens.publishRowGap),
      child: Row(
        children: [
          PublishThumb(item: item, size: HomeDimens.publishRowThumb),
          SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.postPublishRowTitle(number),
                  style: context.text.name,
                  color: colors.textPrimary,
                ),
                if (item.state == ContentLineState.sending)
                  Padding(
                    padding: EdgeInsets.only(top: AppSpacing.s4),
                    child: PublishBar(
                      value: item.progress == 0 ? null : item.progress,
                    ),
                  )
                else
                  AppText(
                    _status(context),
                    style: context.text.caption,
                    color: _statusColor(context),
                  ),
              ],
            ),
          ),
          if (item.state == ContentLineState.failed) ..._actions(context),
        ],
      ),
    );
  }

  String _status(BuildContext context) => switch (item.state) {
    ContentLineState.done => context.l10n.postPublishRowPosted,
    ContentLineState.failed => context.l10n.postPublishFailed,
    _ => context.l10n.postPublishRowWaiting,
  };

  Color _statusColor(BuildContext context) {
    final colors = context.appColors;
    return switch (item.state) {
      ContentLineState.done => colors.primary,
      ContentLineState.failed => colors.danger,
      _ => colors.textSecondary,
    };
  }

  List<Widget> _actions(BuildContext context) {
    final cubit = context.read<PostPublishCubit>();
    return [
      TextButton(
        onPressed: () => cubit.discard(item.id),
        child: Text(context.l10n.postPublishDiscard),
      ),
      if (item.canRetry)
        TextButton(
          onPressed: () => cubit.retry(item.id),
          child: Text(context.l10n.retry),
        ),
    ];
  }
}
