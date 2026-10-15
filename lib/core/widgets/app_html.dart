import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import 'app_safe_area.dart';

/// Backend HTML as native widgets, styled with the app's text styles and colors (h1-h3, p, lists,
/// links). Direction and text scale come from the surrounding [Directionality] and [MediaQuery].
/// Scrolls on its own; [onLinkTap] gets the tapped `href`.
class AppHtml extends StatelessWidget {
  const AppHtml({
    super.key,
    required this.html,
    this.onLinkTap,
    this.style,
    this.padding,
  });

  final String html;
  final ValueChanged<String?>? onLinkTap;
  final Map<String, Style>? style;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.text;

    Style heading(TextStyle base) => Style(
      fontFamily: base.fontFamily,
      fontSize: FontSize(base.fontSize ?? 16),
      fontWeight: base.fontWeight,
      color: colors.textPrimary,
      lineHeight: LineHeight(base.height ?? 1.3),
      margin: Margins.only(top: AppSpacing.s20, bottom: AppSpacing.s8),
    );

    return AppSafeArea(
      child: SingleChildScrollView(
        padding:
            padding ??
            EdgeInsets.fromLTRB(
              AppSpacing.formSide,
              AppSpacing.s8,
              AppSpacing.formSide,
              AppSpacing.s32,
            ),
        child: Html(
          data: html,
          onLinkTap: onLinkTap == null ? null : (url, _, _) => onLinkTap!(url),
          style:
              style ??
              {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontFamily: text.body.fontFamily,
                  fontSize: FontSize(text.body.fontSize ?? 15),
                  fontWeight: text.body.fontWeight,
                  lineHeight: LineHeight(text.body.height ?? 1.55),
                  color: colors.textPrimary,
                ),
                'h1': heading(text.title),
                'h2': heading(text.titleSm),
                'h3': heading(text.name),
                'p': Style(margin: Margins.only(bottom: AppSpacing.s12)),
                'li': Style(padding: HtmlPaddings.only(bottom: AppSpacing.s4)),
                'a': Style(
                  color: colors.primary,
                  textDecoration: TextDecoration.underline,
                ),
              },
        ),
      ),
    );
  }
}
