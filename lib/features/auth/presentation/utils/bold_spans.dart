import 'package:flutter/painting.dart';

/// [text] as spans with the first occurrence of [emphasis] in bold (the masked email inside a sentence).
/// Without an [emphasis], or when it is not found, the whole text is one plain span.
List<InlineSpan> boldSpans(String text, String? emphasis, TextStyle base) {
  final start = emphasis == null ? -1 : text.indexOf(emphasis);
  if (start < 0) return [TextSpan(text: text)];
  final end = start + emphasis!.length;
  return [
    TextSpan(text: text.substring(0, start)),
    TextSpan(
      text: emphasis,
      style: base.copyWith(fontWeight: FontWeight.w700),
    ),
    TextSpan(text: text.substring(end)),
  ];
}
