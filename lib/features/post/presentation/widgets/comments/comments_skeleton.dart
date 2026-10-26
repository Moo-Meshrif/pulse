import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/comments_dimens.dart';

/// What the sheet shows before the first comments arrive: one comment row as shapes under the shimmer.
class CommentsSkeleton extends StatelessWidget {
  const CommentsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: context.l10n.loading,
    child: ExcludeSemantics(
      child: Skeletonizer.zone(
        effect: skeletonEffect(context),
        child: const _Row(),
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row();

  @override
  Widget build(BuildContext context) => Padding(
    padding: CommentsDimens.rowPadding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bone.circle(size: CommentsDimens.avatar),
        SizedBox(width: CommentsDimens.avatarGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.text(
                width: CommentsDimens.skeletonNameWidth,
                style: context.text.caption,
              ),
              SizedBox(height: CommentsDimens.skeletonLineGap),
              const Bone.multiText(lines: 2),
            ],
          ),
        ),
      ],
    ),
  );
}
