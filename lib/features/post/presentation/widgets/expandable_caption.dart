import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text.dart';
import '../dimens/post_card_dimens.dart';
import '../utils/caption_overflow.dart';
import 'post_tap_button.dart';

/// A post's caption: collapsed to a few lines with "more"; "less" closes it and scrolls back to the start of
/// the caption. A caption that fits has no control.
class ExpandableCaption extends StatefulWidget {
  const ExpandableCaption({
    super.key,
    required this.text,
    required this.collapsedLines,
    this.margin,
    this.showAll = false,
  });

  final String text;
  final int collapsedLines;
  final EdgeInsetsGeometry? margin;

  /// The post's own page: the whole caption, no "more".
  final bool showAll;

  @override
  State<ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<ExpandableCaption> {
  bool _isExpanded = false;

  /// The collapsed text comes from laying out the caption, so it is kept until an input changes.
  ({
    String text,
    double width,
    TextScaler scaler,
    String label,
    int lines,
    String? cut,
  })?
  _measured;

  String? _collapsedText(
    BuildContext context,
    TextStyle style,
    TextStyle moreStyle,
    String label,
    double width,
  ) {
    final scaler = MediaQuery.textScalerOf(context);
    final last = _measured;
    if (last != null &&
        last.text == widget.text &&
        last.width == width &&
        last.lines == widget.collapsedLines &&
        last.scaler == scaler &&
        last.label == label) {
      return last.cut;
    }
    final cut = collapsedCaptionText(
      context,
      text: widget.text,
      style: style,
      moreStyle: moreStyle,
      moreLabel: label,
      width: width,
      maxLines: widget.collapsedLines,
    );
    _measured = (
      text: widget.text,
      width: width,
      scaler: scaler,
      label: label,
      lines: widget.collapsedLines,
      cut: cut,
    );
    return cut;
  }

  void _toggle() {
    final wasExpanded = _isExpanded;
    setState(() => _isExpanded = !wasExpanded);
    if (!wasExpanded) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(context, duration: PostMotion.scrollBack);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = context.text.bodySm.copyWith(color: colors.textPrimary);
    final moreStyle = context.text.moreLink.copyWith(color: colors.primary);
    if (widget.showAll) {
      return Padding(
        padding: widget.margin ?? EdgeInsets.zero,
        child: Text(widget.text, style: style),
      );
    }
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final moreLabel = context.l10n.postMore;
          final cut = _collapsedText(
            context,
            style,
            moreStyle,
            moreLabel,
            constraints.maxWidth,
          );
          if (cut == null) return Text(widget.text, style: style);
          if (!_isExpanded) {
            return PostTapButton(
              label: moreLabel,
              onTap: _toggle,
              child: Text.rich(
                TextSpan(
                  style: style,
                  children: [
                    TextSpan(text: '$cut… '),
                    TextSpan(text: moreLabel, style: moreStyle),
                  ],
                ),
              ),
            );
          }
          final lessLabel = context.l10n.postLess;
          return PostTapButton(
            label: lessLabel,
            onTap: _toggle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.text, style: style),
                Padding(
                  padding: EdgeInsets.only(top: PostCardDimens.actionGap),
                  child: AppText(
                    lessLabel,
                    style: context.text.moreLink,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
