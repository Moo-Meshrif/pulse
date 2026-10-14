import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text.dart';
import '../utils/caption_overflow.dart';
import 'post_tap_button.dart';

/// A post's caption: collapsed to a few lines with "more"; "less" closes it and scrolls back to the start of
/// the caption. A caption that fits has no control.
class ExpandableCaption extends StatefulWidget {
  const ExpandableCaption({super.key, required this.text, this.margin});

  final String text;
  final EdgeInsetsGeometry? margin;

  @override
  State<ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<ExpandableCaption> {
  bool _isExpanded = false;

  /// The overflow check lays out the text, so it is kept until the text, width or text scale changes.
  ({String text, double width, TextScaler scaler, bool overflows})? _measured;

  bool _canExpand(BuildContext context, TextStyle style, double width) {
    final scaler = MediaQuery.textScalerOf(context);
    final last = _measured;
    if (last != null &&
        last.text == widget.text &&
        last.width == width &&
        last.scaler == scaler) {
      return last.overflows;
    }
    final overflows = doesCaptionOverflow(
      context,
      text: widget.text,
      style: style,
      width: width,
    );
    _measured = (
      text: widget.text,
      width: width,
      scaler: scaler,
      overflows: overflows,
    );
    return overflows;
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
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canExpand = _canExpand(context, style, constraints.maxWidth);
          final isCollapsed = canExpand && !_isExpanded;
          final label = _isExpanded
              ? context.l10n.postLess
              : context.l10n.postMore;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                style: style,
                maxLines: isCollapsed
                    ? PostCardDimens.captionCollapsedLines
                    : null,
                overflow: isCollapsed ? TextOverflow.ellipsis : null,
              ),
              if (canExpand)
                PostTapButton(
                  label: label,
                  onTap: _toggle,
                  child: Padding(
                    padding: EdgeInsets.only(top: PostCardDimens.actionGap),
                    child: AppText(
                      label,
                      style: context.text.moreLink,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
