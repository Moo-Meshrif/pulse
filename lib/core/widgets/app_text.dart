import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// The app's text widget: `style` is an `AppTextStyles` token and `color` comes from `AppColors`. A size or
/// weight no token has is a new token, not a `copyWith`.
class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final base = style ?? context.text.body;
    return Text(
      text,
      style: color == null ? base : base.copyWith(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines == null ? null : TextOverflow.ellipsis),
    );
  }
}
