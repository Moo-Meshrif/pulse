import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../post/domain/entity/post_publish_status.dart';
import '../../cubit/post_publish_cubit.dart';
import '../../dimens/home_dimens.dart';

/// The post being shared or saved, above the feed: a thumbnail and a progress line while it goes out, or
/// "couldn't post" with Retry and Discard. It is not there when nothing is being sent.
class PublishBanner extends StatelessWidget {
  const PublishBanner({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PostPublishCubit, PostPublishStatus>(
        builder: (context, status) => switch (status) {
          PostPublishing(:final isEdit, :final previewPath) => _Card(
            previewPath: previewPath,
            title: isEdit
                ? context.l10n.postPublishSaving
                : context.l10n.postPublishing,
            progress: const LinearProgressIndicator(),
          ),
          PostPublishFailed(:final isEdit, :final previewPath) => _Card(
            previewPath: previewPath,
            title: isEdit
                ? context.l10n.editPostSaveFailed
                : context.l10n.postPublishFailed,
            isFailed: true,
            actions: const _FailedActions(),
          ),
          PostPublishIdle() || PostPublishDone() => const SizedBox.shrink(),
        },
      );
}

class _Card extends StatelessWidget {
  const _Card({
    required this.previewPath,
    required this.title,
    this.progress,
    this.actions,
    this.isFailed = false,
  });

  final String? previewPath;
  final String title;
  final Widget? progress;
  final Widget? actions;
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final path = previewPath;
    return Padding(
      padding: HomeDimens.listPadding.copyWith(bottom: HomeDimens.cardGap),
      child: Container(
        padding: HomeDimens.publishPadding,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.settingsTile),
              child: SizedBox.square(
                dimension: HomeDimens.publishThumb,
                child: path == null
                    ? ColoredBox(color: colors.surfaceMuted)
                    : Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            ColoredBox(color: colors.surfaceMuted),
                      ),
              ),
            ),
            SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    style: context.text.name,
                    color: isFailed ? colors.danger : colors.textPrimary,
                  ),
                  if (progress != null) ...[
                    SizedBox(height: AppSpacing.s8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        HomeDimens.publishProgress,
                      ),
                      child: SizedBox(
                        height: HomeDimens.publishProgress,
                        child: progress,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?actions,
          ],
        ),
      ),
    );
  }
}

class _FailedActions extends StatelessWidget {
  const _FailedActions();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostPublishCubit>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: cubit.discard,
          child: Text(context.l10n.postPublishDiscard),
        ),
        TextButton(onPressed: cubit.retry, child: Text(context.l10n.retry)),
      ],
    );
  }
}
