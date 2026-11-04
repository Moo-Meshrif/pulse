import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/notice/notices.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../utils/comment_mentions.dart';

/// The words of a comment with each `@username` in the primary color; a tap opens that profile.
class CommentBody extends StatefulWidget {
  const CommentBody(this.body, {super.key, this.mentionIds = const {}});

  final String body;
  final Map<String, String> mentionIds;

  @override
  State<CommentBody> createState() => _CommentBodyState();
}

// Left-to-right isolate marks.
final _ltrStart = String.fromCharCode(0x2066);
final _ltrEnd = String.fromCharCode(0x2069);

class _CommentBodyState extends State<CommentBody> {
  final _taps = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _clearTaps();
    super.dispose();
  }

  void _clearTaps() {
    for (final tap in _taps) {
      tap.dispose();
    }
    _taps.clear();
  }

  void _open(String username) {
    final id = widget.mentionIds[username.toLowerCase()];
    if (id == null) {
      Notices.error(context.l10n.otherProfileNotFound);
      return;
    }
    AppNavigator.push<void>(context, AppRoutes.profileOf(id));
  }

  InlineSpan _span(CommentPart part, Color color) {
    final username = part.username;
    if (username == null) return TextSpan(text: part.text);
    final tap = TapGestureRecognizer()..onTap = () => _open(username);
    _taps.add(tap);
    // The isolate keeps `@name` in left-to-right order inside Arabic text.
    return TextSpan(
      text: '$_ltrStart${part.text}$_ltrEnd',
      style: TextStyle(color: color),
      recognizer: tap,
      semanticsLabel: part.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    _clearTaps();
    final colors = context.appColors;
    return Text.rich(
      TextSpan(
        children: [
          for (final part in CommentMentions.split(widget.body))
            _span(part, colors.primary),
        ],
      ),
      style: context.text.bodySm.copyWith(color: colors.textPrimary),
    );
  }
}
