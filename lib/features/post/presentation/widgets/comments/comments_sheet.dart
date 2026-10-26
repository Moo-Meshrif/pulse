import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/extensions/notice_context.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/comment_sort.dart';
import '../../cubit/comment_mentions/comment_mentions_cubit.dart';
import '../../cubit/comments/comments_cubit.dart';
import '../../cubit/comments/comments_state.dart';
import '../../dimens/comments_dimens.dart';
import '../../utils/enums/comments_status.dart';
import 'comment_composer.dart';
import 'comment_sort_chip.dart';
import 'comments_empty.dart';
import 'comments_list.dart';
import 'comments_off_bar.dart';
import 'comments_skeleton.dart';

/// The comments of a post (docs/specs/post/screens/s14-comments-sheet.md): comments and replies, the sort,
/// likes, and the empty and error states.
abstract final class CommentsSheet {
  /// Shows the sheet for [postId]. [focusCommentId] puts that comment (or its thread) first.
  /// [commentsEnabled] false shows a bar instead of the field. [isPostOwner] lets you hide comments. [fromCommentIcon] opens the keyboard when
  /// there are no comments. [onCountChanged] gets how many comments this sheet added to the post (more or
  /// less than before), so the card can follow.
  static Future<void> show(
    BuildContext context, {
    required String postId,
    String? focusCommentId,
    bool commentsEnabled = true,
    bool isPostOwner = false,
    bool fromCommentIcon = false,
    ValueChanged<int>? onCountChanged,
  }) => AppBottomSheet.show<void>(
    context,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<CommentsCubit>(param1: postId, param2: focusCommentId)
                ..load(),
        ),
        BlocProvider(
          create: (_) => getIt<CommentMentionsCubit>(param1: postId),
        ),
      ],
      child: _Body(
        commentsEnabled: commentsEnabled,
        isPostOwner: isPostOwner,
        focusWhenEmpty: fromCommentIcon,
        onCountChanged: onCountChanged,
      ),
    ),
  );
}

class _Body extends StatelessWidget {
  const _Body({
    required this.commentsEnabled,
    required this.isPostOwner,
    required this.focusWhenEmpty,
    required this.onCountChanged,
  });

  final bool commentsEnabled;
  final bool isPostOwner;
  final bool focusWhenEmpty;
  final ValueChanged<int>? onCountChanged;

  // The sheet's own padding and grabber are inside the gap from the screen top; the keyboard takes its
  // height from the list, so the sheet's top stays where it is.
  double _height(BuildContext context) =>
      MediaQuery.sizeOf(context).height -
      MediaQuery.viewInsetsOf(context).bottom -
      CommentsDimens.topGap -
      BottomSheetDimens.topPadding -
      BottomSheetDimens.grabberHeight -
      BottomSheetDimens.grabberToTitleGap -
      BottomSheetDimens.bottomPadding;

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<CommentsCubit, CommentsState>(
        listenWhen: (before, now) =>
            now.failure != null && before.failure != now.failure,
        listener: (context, state) => context.showFailure(state.failure),
      ),
      BlocListener<CommentsCubit, CommentsState>(
        listenWhen: (before, now) => before.countDelta != now.countDelta,
        listener: (context, state) => onCountChanged?.call(state.countDelta),
      ),
    ],
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: _height(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            const _Divider(),
            SizedBox(height: CommentsDimens.dividerGap),
            Expanded(
              child: _Content(
                commentsEnabled: commentsEnabled,
                isPostOwner: isPostOwner,
              ),
            ),
            const _Divider(),
            if (commentsEnabled)
              CommentComposer(focusWhenEmpty: focusWhenEmpty)
            else
              const CommentsOffBar(),
          ],
        ),
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Divider(
    height: CommentsDimens.divider,
    thickness: CommentsDimens.divider,
    color: context.appColors.divider,
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: CommentsDimens.headerGap),
    child: Row(
      children: [
        Expanded(
          child: AppText(
            context.l10n.commentsTitle,
            style: context.text.sheetTitle,
            color: context.appColors.textPrimary,
            maxLines: 1,
          ),
        ),
        BlocSelector<CommentsCubit, CommentsState, CommentSort>(
          selector: (state) => state.sort,
          builder: (context, sort) => CommentSortChip(
            sort: sort,
            onChanged: context.read<CommentsCubit>().changeSort,
          ),
        ),
      ],
    ),
  );
}

/// The first page's three outcomes; an empty page is the empty tile.
class _Content extends StatelessWidget {
  const _Content({required this.commentsEnabled, required this.isPostOwner});

  final bool commentsEnabled;
  final bool isPostOwner;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CommentsCubit, CommentsState>(
        buildWhen: (before, now) =>
            before.status != now.status || _isEmpty(before) != _isEmpty(now),
        builder: (context, state) => switch (state.status) {
          CommentsStatus.loading => const CommentsSkeleton(),
          CommentsStatus.failed => AppEmpty.failed(
            onRetry: context.read<CommentsCubit>().load,
          ),
          CommentsStatus.ready =>
            _isEmpty(state)
                ? const CommentsEmpty()
                : CommentsList(
                    commentsEnabled: commentsEnabled,
                    isPostOwner: isPostOwner,
                  ),
        },
      );
}

/// No comments and none being sent.
bool _isEmpty(CommentsState state) =>
    state.comments.isEmpty && state.pending.isEmpty;
