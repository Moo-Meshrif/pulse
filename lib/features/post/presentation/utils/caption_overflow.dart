import 'package:flutter/widgets.dart';

import '../dimens/post_card_dimens.dart';

bool doesCaptionOverflow(
  BuildContext context, {
  required String text,
  required TextStyle style,
  required double width,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: PostCardDimens.captionCollapsedLines,
  )..layout(maxWidth: width);
  final overflows = painter.didExceedMaxLines;
  painter.dispose();
  return overflows;
}
