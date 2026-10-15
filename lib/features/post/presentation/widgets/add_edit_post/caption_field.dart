import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_composer_dimens.dart';
import '../../utils/new_post_limits.dart';

/// The caption: a borderless multiline field that grows with its text, and the counter under it.
/// It starts with [initial] and reports every change to [onChanged].
class CaptionField extends StatefulWidget {
  const CaptionField({super.key, this.initial = '', required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<CaptionField> createState() => _CaptionFieldState();
}

class _CaptionFieldState extends State<CaptionField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: PostComposerDimens.inputMinHeight,
          ),
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            minLines: null,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [
              LengthLimitingTextInputFormatter(NewPostLimits.maxCaption),
            ],
            style: context.text.input.copyWith(
              color: colors.textPrimary,
              textBaseline: TextBaseline
                  .alphabetic, // TextField asserts on it when inherit is false
            ),
            decoration: InputDecoration.collapsed(
              hintText: context.l10n.newPostHint,
              hintStyle: context.text.input.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
        _CaptionCounter(controller: _controller),
      ],
    );
  }
}

class _CaptionCounter extends StatelessWidget {
  const _CaptionCounter({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final length = value.text.length;
        final atLimit = length >= NewPostLimits.maxCaption;
        return Semantics(
          liveRegion: atLimit,
          label: atLimit
              ? context.l10n.newPostCounterAtLimit(
                  length,
                  NewPostLimits.maxCaption,
                )
              : null,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppText(
              '$length/${NewPostLimits.maxCaption}',
              style: context.text.caption,
              color: atLimit ? colors.danger : colors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}
