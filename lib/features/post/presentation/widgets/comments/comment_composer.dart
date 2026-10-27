import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entity/comment_entity.dart';
import '../../../domain/entity/mention_person_entity.dart';
import '../../cubit/comment_mentions/comment_mentions_cubit.dart';
import '../../cubit/comments/comments_cubit.dart';
import '../../cubit/comments/comments_state.dart';
import '../../dimens/comments_dimens.dart';
import '../../utils/comment_text.dart';
import '../../utils/enums/comments_status.dart';
import '../../utils/mention_query.dart';
import '../post_person_avatar.dart';
import 'comment_emoji_row.dart';
import 'comment_mention_list.dart';
import 'comment_replying_strip.dart';

/// The pinned writing area: the replying strip, quick emoji, the field with its counter and Send. The text
/// is kept for the post when the sheet closes.
class CommentComposer extends StatefulWidget {
  const CommentComposer({
    super.key,
    this.focusWhenEmpty = false,
    this.focusNode,
  });

  /// Opens the keyboard once the sheet turns out to have no comments.
  final bool focusWhenEmpty;

  /// The page's handle on the field (its comment icon puts the cursor here); the composer makes its own
  /// when none is given.
  final FocusNode? focusNode;

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  late final CommentsCubit _cubit = context.read<CommentsCubit>();
  late final _controller = TextEditingController(text: _cubit.draft);
  late final _focus = widget.focusNode ?? FocusNode();
  MentionQuery? _mention;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  /// Asks for people while an `@word` is under the cursor; the list hides when there is none.
  void _onTextChanged() {
    final mention = MentionQuery.find(_controller.value);
    if (mention == _mention) return;
    _mention = mention;
    context.read<CommentMentionsCubit>().queryChanged(mention?.text);
  }

  void _pickMention(MentionPersonEntity person) {
    final mention = _mention;
    if (mention == null) return;
    _controller.value = mention.pick(_controller.value, person.username);
    _focus.requestFocus();
  }

  @override
  void dispose() {
    if (_cubit.state.editing == null) _cubit.saveDraft(_controller.text);
    _controller.dispose();
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  /// Starts the field with `@name` only when the reply is to someone other than the author of the thread's
  /// first comment (every reply already goes to that person) and other than you.
  void _startReply(CommentEntity comment) {
    final parentId = comment.parentId;
    final threadAuthorId = parentId == null
        ? comment.authorId
        : _cubit.state.comments
              .where((c) => c.id == parentId)
              .map((c) => c.authorId)
              .firstOrNull;
    if (comment.authorId == threadAuthorId ||
        comment.authorId == _cubit.me?.id) {
      _focus.requestFocus();
      return;
    }
    final text = CommentText.withMention(_controller.text, comment.username);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _focus.requestFocus();
  }

  void _cancelReply(String username) {
    if (_controller.text.trim() == '@$username') _controller.clear();
    _cubit.cancelReply();
  }

  void _addEmoji(String emoji) {
    _controller.value = CommentText.insert(_controller.value, emoji);
    _focus.requestFocus();
  }

  void _startEdit(String body) {
    _controller.value = TextEditingValue(
      text: body,
      selection: TextSelection.collapsed(offset: body.length),
    );
    _focus.requestFocus();
  }

  void _send() {
    final text = _controller.text;
    if (_cubit.state.editing != null) {
      _cubit.saveEdit(text);
      return;
    }
    final reply = _cubit.state.replyTo?.username;
    if (!CommentText.canSend(text, replyUsername: reply)) return;
    _controller.clear();
    _cubit.send(text);
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      // First, so a reply opened over an edit starts from an empty field.
      BlocListener<CommentsCubit, CommentsState>(
        listenWhen: (before, now) => before.editing?.id != now.editing?.id,
        listener: (context, state) {
          final editing = state.editing;
          if (editing == null) {
            _controller.clear();
          } else {
            _startEdit(editing.body);
          }
        },
      ),
      BlocListener<CommentsCubit, CommentsState>(
        listenWhen: (before, now) =>
            now.replyTo != null && before.replyTo?.id != now.replyTo?.id,
        listener: (context, state) => _startReply(state.replyTo!),
      ),
      BlocListener<CommentsCubit, CommentsState>(
        listenWhen: (before, now) =>
            now.emoji != null && before.emoji != now.emoji,
        listener: (context, state) => _addEmoji(state.emoji!),
      ),
      BlocListener<CommentsCubit, CommentsState>(
        listenWhen: (before, now) =>
            widget.focusWhenEmpty &&
            before.status != now.status &&
            now.status == CommentsStatus.ready &&
            now.comments.isEmpty,
        listener: (context, state) => _focus.requestFocus(),
      ),
    ],
    child: Padding(
      padding: EdgeInsets.only(top: CommentsDimens.composerTop),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<CommentMentionsCubit, List<MentionPersonEntity>>(
            builder: (context, people) => people.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(
                      bottom: CommentsDimens.composerTop,
                    ),
                    child: CommentMentionList(
                      people: people,
                      onPick: _pickMention,
                    ),
                  ),
          ),
          BlocSelector<CommentsCubit, CommentsState, String?>(
            selector: (state) => state.replyTo?.username,
            builder: (context, username) => username == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(
                      bottom: CommentsDimens.composerTop,
                    ),
                    child: CommentReplyingStrip(
                      username: username,
                      onCancel: () => _cancelReply(username),
                    ),
                  ),
          ),
          BlocSelector<CommentsCubit, CommentsState, bool>(
            selector: (state) => state.editing != null,
            builder: (context, editing) => editing
                ? Padding(
                    padding: EdgeInsets.only(
                      bottom: CommentsDimens.composerTop,
                    ),
                    child: CommentEditingStrip(onCancel: _cubit.cancelEdit),
                  )
                : const SizedBox.shrink(),
          ),
          CommentEmojiRow(onEmoji: _addEmoji),
          _FieldRow(
            controller: _controller,
            focus: _focus,
            me: _cubit.me?.id,
            name: _cubit.me?.fullName ?? _cubit.me?.username,
            avatarUrl: _cubit.me?.avatarUrl,
            onSend: _send,
          ),
        ],
      ),
    ),
  );
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.controller,
    required this.focus,
    required this.me,
    required this.name,
    required this.avatarUrl,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final String? me;
  final String? name;
  final String? avatarUrl;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<CommentsCubit, CommentsState, String?>(
        selector: (state) => state.replyTo?.username,
        builder: (context, replyUsername) =>
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final canSend = CommentText.canSend(
                  value.text,
                  replyUsername: replyUsername,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (value.text.length >= CommentText.counterFrom)
                      _Counter(length: value.text.length),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (me != null) ...[
                          PostPersonAvatar(
                            id: me!,
                            name: name ?? '',
                            url: avatarUrl,
                            size: CommentsDimens.avatar,
                          ),
                          SizedBox(width: CommentsDimens.composerGap),
                        ],
                        Expanded(
                          child: _Field(
                            controller: controller,
                            focus: focus,
                            onSend: onSend,
                          ),
                        ),
                        SizedBox(width: CommentsDimens.composerGap),
                        _SendButton(enabled: canSend, onTap: onSend),
                      ],
                    ),
                  ],
                );
              },
            ),
      );
}

class _Counter extends StatelessWidget {
  const _Counter({required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(bottom: CommentsDimens.counterGap),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: AppText(
          context.l10n.commentsCounter(length),
          style: context.text.caption,
          color: length >= CommentText.maxLength
              ? colors.danger
              : colors.textSecondary,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focus,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = BorderRadius.circular(CommentsDimens.fieldRadius);
    return TextField(
      controller: controller,
      focusNode: focus,
      minLines: 1,
      maxLines: CommentsDimens.fieldMaxLines,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.send,
      textCapitalization: TextCapitalization.sentences,
      inputFormatters: [
        LengthLimitingTextInputFormatter(CommentText.maxLength),
      ],
      onSubmitted: (_) => onSend(),
      style: context.text.input.copyWith(
        color: colors.textPrimary,
        textBaseline: TextBaseline
            .alphabetic, // TextField asserts on it when inherit is false
      ),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        hintText: context.l10n.commentsAddHint,
        hintStyle: context.text.input.copyWith(color: colors.textSecondary),
        filled: true,
        fillColor: colors.background,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: CommentsDimens.fieldSide,
          vertical: CommentsDimens.fieldVertical,
        ),
        constraints: BoxConstraints(minHeight: CommentsDimens.fieldMinHeight),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: colors.primary,
            width: CommentsDimens.fieldRing,
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      enabled: enabled,
      excludeSemantics: true,
      label: context.l10n.commentsSend,
      child: InkResponse(
        onTap: enabled ? onTap : null,
        radius: CommentsDimens.sendTarget / 2,
        child: SizedBox(
          width: CommentsDimens.sendTarget,
          height: CommentsDimens.fieldMinHeight,
          child: Center(
            child: Container(
              width: CommentsDimens.send,
              height: CommentsDimens.send,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled ? colors.primary : colors.divider,
              ),
              child: Center(
                child: AppSvgIcon(
                  AppAssets.send,
                  size: CommentsDimens.sendIcon,
                  color: enabled ? colors.textOnPrimary : colors.textSecondary,
                  directional: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
