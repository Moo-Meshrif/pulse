import 'package:flutter/widgets.dart';

/// The part of [text] that stays visible when the caption is collapsed, so that "… [moreLabel]" ends the last
/// line, cut between words; null when the whole caption fits in the collapsed lines.
String? collapsedCaptionText(
  BuildContext context, {
  required String text,
  required TextStyle style,
  required TextStyle moreStyle,
  required String moreLabel,
  required double width,
  required int maxLines,
}) {
  final direction = Directionality.of(context);
  final scaler = MediaQuery.textScalerOf(context);

  bool exceeds(InlineSpan span) {
    final painter = TextPainter(
      text: span,
      textDirection: direction,
      textScaler: scaler,
      maxLines: maxLines,
    )..layout(maxWidth: width);
    final result = painter.didExceedMaxLines;
    painter.dispose();
    return result;
  }

  if (!exceeds(TextSpan(text: text, style: style))) return null;

  bool fits(int length) => !exceeds(
    TextSpan(
      style: style,
      children: [
        TextSpan(text: '${text.substring(0, length).trimRight()}… '),
        TextSpan(text: moreLabel, style: moreStyle),
      ],
    ),
  );

  var low = 0;
  var high = text.length;
  while (low < high) {
    final mid = (low + high + 1) ~/ 2;
    if (fits(mid)) {
      low = mid;
    } else {
      high = mid - 1;
    }
  }
  final cut = text.substring(0, low);
  final startsNewWord = low < text.length && !RegExp(r'\s').hasMatch(text[low]);
  final lastSpace = cut.lastIndexOf(RegExp(r'\s'));
  if (startsNewWord && lastSpace > 0) {
    return cut.substring(0, lastSpace).trimRight();
  }
  return cut.trimRight();
}
