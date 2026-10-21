import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/enums/mood_kind.dart';
import '../utils/post_card_callbacks.dart';
import '../utils/post_card_data.dart';
import '../utils/post_feeling.dart';

/// The line of the author row: name, what they feel and who they are with. Names are bold and tap through
/// to a profile, the words between are grey, and it stops at two lines.
class PostHeadline extends StatefulWidget {
  const PostHeadline({super.key, required this.data, required this.callbacks});

  final PostCardData data;
  final PostCardCallbacks callbacks;

  @override
  State<PostHeadline> createState() => _PostHeadlineState();
}

class _PostHeadlineState extends State<PostHeadline> {
  static const _maxLines = 2;

  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  TextSpan _name(String text, TextStyle style, VoidCallback? onTap) {
    TapGestureRecognizer? recognizer;
    if (onTap != null) {
      recognizer = TapGestureRecognizer()..onTap = onTap;
      _recognizers.add(recognizer);
    }
    return TextSpan(text: text, style: style, recognizer: recognizer);
  }

  String _personName(int index) {
    final tag = widget.data.tags[index];
    final fullName = tag.fullName?.trim();
    return fullName == null || fullName.isEmpty ? tag.username ?? '' : fullName;
  }

  /// "shared {author}'s post", or "shared a post" when the author is unknown (the original is gone).
  void _addShared(
    List<InlineSpan> spans,
    PostCardData data,
    PostCardCallbacks callbacks,
    TextStyle connector,
    TextStyle name,
    AppLocalizations l10n,
  ) {
    final original = data.original;
    if (original == null) {
      spans.add(TextSpan(text: l10n.postHeadlineSharedAPost, style: connector));
      return;
    }
    spans
      ..add(TextSpan(text: l10n.postHeadlineShared, style: connector))
      ..add(_name(original.authorName, name, callbacks.onOriginalProfile))
      ..add(TextSpan(text: l10n.postHeadlineSharedPostOf, style: connector));
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final data = widget.data;
    final callbacks = widget.callbacks;
    final l10n = context.l10n;
    final colors = context.appColors;
    final connector = context.text.headline.copyWith(
      color: colors.textSecondary,
    );
    final name = context.text.headlineName.copyWith(color: colors.textPrimary);

    final spans = <InlineSpan>[
      _name(
        data.isMine ? l10n.postHeadlineYou : data.authorName,
        name,
        callbacks.onProfile,
      ),
    ];

    if (data.isShare) _addShared(spans, data, callbacks, connector, name, l10n);

    final mood = data.mood;
    if (mood != null && mood.kind == MoodKind.feeling) {
      final emoji = feelingEmoji(mood.key);
      final word = feelingWord(l10n, mood.key);
      if (emoji != null && word != null) {
        spans.add(
          TextSpan(
            text: ' ${l10n.postHeadlineFeeling(emoji, word)}',
            style: connector,
          ),
        );
      }
    }

    final named = data.tags.length;
    if (data.tagCount > 0 && named > 0) {
      void tapPerson(int index) =>
          callbacks.onTaggedPerson?.call(data.tags[index].userId);
      final showsSecondName = data.tagCount == 2 && named > 1;
      spans
        ..add(TextSpan(text: ' ${l10n.postHeadlineWith}', style: connector))
        ..add(_name(_personName(0), name, () => tapPerson(0)));
      if (showsSecondName) {
        spans
          ..add(TextSpan(text: l10n.postHeadlineAnd, style: connector))
          ..add(_name(_personName(1), name, () => tapPerson(1)));
      } else if (data.tagCount > 1) {
        spans
          ..add(TextSpan(text: l10n.postHeadlineAnd, style: connector))
          ..add(
            _name(
              l10n.postHeadlineOthers(data.tagCount - 1),
              name,
              callbacks.onTaggedPeople,
            ),
          );
      }
    }

    return Text.rich(
      TextSpan(children: spans, style: connector),
      maxLines: _maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
