import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../cubit/new_post_cubit.dart';
import '../../cubit/new_post_state.dart';
import '../../dimens/post_composer_dimens.dart';
import '../../utils/new_post_limits.dart';

/// The caption: a borderless multiline field that grows with its text, and the counter under it.
class CaptionField extends StatefulWidget {
  const CaptionField({super.key});

  @override
  State<CaptionField> createState() => _CaptionFieldState();
}

class _CaptionFieldState extends State<CaptionField> {
  final _controller = TextEditingController();

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
            onChanged: context.read<NewPostCubit>().captionChanged,
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
        const _CaptionCounter(),
      ],
    );
  }
}

class _CaptionCounter extends StatelessWidget {
  const _CaptionCounter();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocSelector<NewPostCubit, NewPostState, int>(
      selector: (state) => state.caption.length,
      builder: (context, length) {
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
