import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';

/// Questions that open to their answer, one at a time. Which one is open is local to the widget.
class FaqAccordion extends StatefulWidget {
  const FaqAccordion({super.key, required this.items});

  final List<FaqItem> items;

  @override
  State<FaqAccordion> createState() => _FaqAccordionState();
}

class FaqItem {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

class _FaqAccordionState extends State<FaqAccordion> {
  int? _open;

  void _toggle(int index) =>
      setState(() => _open = _open == index ? null : index);

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    return Column(
      children: [
        for (var i = 0; i < widget.items.length; i++)
          _FaqRow(
            item: widget.items[i],
            open: _open == i,
            animate: animate,
            onTap: () => _toggle(i),
          ),
      ],
    );
  }
}

class _FaqRow extends StatelessWidget {
  const _FaqRow({
    required this.item,
    required this.open,
    required this.animate,
    required this.onTap,
  });

  final FaqItem item;
  final bool open;
  final bool animate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final duration = animate ? SettingsDimens.faqDuration : Duration.zero;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: open,
          excludeSemantics: true,
          label: item.question,
          onTap: onTap,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.settingsTile),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: SettingsDimens.faqRowMinHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SettingsDimens.rowSide,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(item.question, style: context.text.body),
                    ),
                    SizedBox(width: SettingsDimens.rowGap),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: duration,
                      child: AppSvgIcon(
                        AppAssets.chevronDown,
                        size: SettingsDimens.chevron,
                        color: c.iconInactive,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: duration,
          alignment: Alignment.topCenter,
          child: open
              ? Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: SettingsDimens.rowSide,
                    end: SettingsDimens.rowSide,
                    bottom: SettingsDimens.faqAnswerBottom,
                  ),
                  child: AppText(
                    item.answer,
                    style: context.text.bodySm,
                    color: c.textSecondary,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
