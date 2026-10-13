import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_assets.dart';
import '../../enums/report_reason.dart';
import '../../error/failures.dart';
import '../../extensions/failure_l10n.dart';
import '../../extensions/l10n.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/report_note.dart';
import '../app_svg_icon.dart';
import '../app_text.dart';
import '../primary_button.dart';
import 'report_copy.dart';
import 'report_palette.dart';

/// A 44 x 44 round button of the sheet header (close, back).
class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.palette,
    required this.asset,
    required this.label,
    required this.onTap,
    this.directional = false,
  });

  final ReportPalette palette;
  final String asset;
  final String label;
  final VoidCallback onTap;
  final bool directional;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onTap,
      radius: BottomSheetDimens.closeButton / 2,
      child: Container(
        width: BottomSheetDimens.closeButton,
        height: BottomSheetDimens.closeButton,
        decoration: BoxDecoration(
          color: palette.closeFill,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: AppSvgIcon(
          asset,
          size: BottomSheetDimens.closeIcon,
          color: palette.title,
          directional: directional,
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.palette,
    required this.title,
    required this.leading,
    required this.trailing,
  });

  final ReportPalette palette;
  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (leading != null) ...[leading!, SizedBox(width: AppSpacing.s8)],
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: StorySheetDimens.titlePadding,
          ),
          child: AppText(
            title,
            style: context.text.titleSm,
            color: palette.title,
            maxLines: 2,
          ),
        ),
      ),
      ?trailing,
    ],
  );
}

/// Step 1: the target's title and body, then one row per reason.
class ReportReasonsStep extends StatelessWidget {
  const ReportReasonsStep({
    super.key,
    required this.palette,
    required this.copy,
    required this.submitting,
    required this.error,
    required this.onReason,
    required this.onClose,
  });

  final ReportPalette palette;
  final ReportCopy copy;

  /// The reason being sent, or null. Every row ignores taps while one is.
  final ReportReason? submitting;
  final Failure? error;
  final ValueChanged<ReportReason> onReason;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _Header(
        palette: palette,
        title: copy.title,
        leading: null,
        trailing: _HeaderButton(
          palette: palette,
          asset: AppAssets.close,
          label: context.l10n.close,
          onTap: onClose,
        ),
      ),
      SizedBox(height: AppSpacing.s8),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: StorySheetDimens.titlePadding,
        ),
        child: AppText(
          copy.body,
          style: context.text.bodySm,
          color: palette.body,
        ),
      ),
      SizedBox(height: StorySheetDimens.gap),
      DecoratedBox(
        decoration: BoxDecoration(
          color: palette.group,
          borderRadius: BorderRadius.circular(StorySheetDimens.groupRadius),
        ),
        child: Column(
          children: [
            for (final (i, reason) in ReportReason.values.indexed) ...[
              if (i > 0)
                Divider(
                  height: StorySheetDimens.separator,
                  thickness: StorySheetDimens.separator,
                  color: palette.separator,
                ),
              _ReasonRow(
                palette: palette,
                reason: reason,
                busy: submitting == reason,
                enabled: submitting == null,
                onTap: () => onReason(reason),
              ),
            ],
          ],
        ),
      ),
      if (error != null) _ErrorLine(palette: palette, failure: error!),
    ],
  );
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({
    required this.palette,
    required this.reason,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  final ReportPalette palette;
  final ReportReason reason;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: enabled,
    child: InkWell(
      onTap: enabled ? onTap : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: StorySheetDimens.reasonRowHeight,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: StorySheetDimens.rowPaddingH,
            vertical: StorySheetDimens.rowPaddingV,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  reason.l10n(context),
                  style: context.text.body,
                  color: palette.title,
                ),
              ),
              SizedBox(width: StorySheetDimens.rowGap),
              if (busy)
                SizedBox.square(
                  dimension: StorySheetDimens.chevron,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, // unscaled: spinner stroke
                    color: palette.title,
                  ),
                )
              else
                AppSvgIcon(
                  AppAssets.chevronRight,
                  size: StorySheetDimens.chevron,
                  color: palette.chevron,
                  directional: true,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.palette, required this.failure});

  final ReportPalette palette;
  final Failure failure;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: StorySheetDimens.gap),
    child: Semantics(
      liveRegion: true,
      child: AppText(
        failure.l10n(context),
        style: context.text.bodySm,
        color: palette.danger,
      ),
    ),
  );
}

/// Step 2 ("Something else"): a note of 5 to 500 characters, then Send.
class ReportNoteStep extends StatefulWidget {
  const ReportNoteStep({
    super.key,
    required this.palette,
    required this.copy,
    required this.submitting,
    required this.error,
    required this.onBack,
    required this.onSend,
  });

  final ReportPalette palette;
  final ReportCopy copy;
  final bool submitting;
  final Failure? error;
  final VoidCallback onBack;
  final ValueChanged<String> onSend;

  @override
  State<ReportNoteStep> createState() => _ReportNoteStepState();
}

class _ReportNoteStepState extends State<ReportNoteStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          palette: palette,
          title: context.l10n.reportElseTitle,
          leading: _HeaderButton(
            palette: palette,
            asset: AppAssets.arrowBack,
            label: context.l10n.back,
            onTap: widget.submitting ? () {} : widget.onBack,
            directional: true,
          ),
          trailing: null,
        ),
        SizedBox(height: AppSpacing.s8),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: StorySheetDimens.titlePadding,
          ),
          child: AppText(
            context.l10n.reportElseBody,
            style: context.text.bodySm,
            color: palette.body,
          ),
        ),
        SizedBox(height: StorySheetDimens.gap),
        _NoteField(
          palette: palette,
          controller: _controller,
          hint: widget.copy.notePlaceholder,
          enabled: !widget.submitting,
        ),
        if (widget.error != null)
          _ErrorLine(palette: palette, failure: widget.error!),
        SizedBox(height: StorySheetDimens.gap),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => PrimaryButton(
            label: context.l10n.reportSend,
            expand: true,
            buttonHeight: AuthButtonDimens.pillHeight,
            loading: widget.submitting,
            onPressed: ReportNote.canSend(value.text)
                ? () => widget.onSend(value.text.trim())
                : null,
          ),
        ),
      ],
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({
    required this.palette,
    required this.controller,
    required this.hint,
    required this.enabled,
  });

  final ReportPalette palette;
  final TextEditingController controller;
  final String hint;
  final bool enabled;

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.input),
    borderSide: BorderSide(color: color, width: width),
  );

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          enabled: enabled,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          inputFormatters: [
            LengthLimitingTextInputFormatter(ReportNote.maxLength),
          ],
          style: text.body.copyWith(
            color: palette.title,
            textBaseline: TextBaseline
                .alphabetic, // TextField asserts on it when inherit is false
          ),
          cursorColor: palette.fieldFocus,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: text.body.copyWith(
              color: palette.body,
              textBaseline: TextBaseline.alphabetic,
            ),
            contentPadding: EdgeInsets.all(AppSpacing.s16),
            enabledBorder: _border(
              palette.fieldBorder,
              1,
            ), // unscaled: hairline
            disabledBorder: _border(
              palette.fieldBorder,
              1,
            ), // unscaled: hairline
            focusedBorder: _border(
              palette.fieldFocus,
              2,
            ), // unscaled: focus ring
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: AppSpacing.s4),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppText(
                context.l10n.reportNoteCounter(
                  value.text.length,
                  ReportNote.maxLength,
                ),
                style: text.caption,
                color: ReportNote.isAtLimit(value.text)
                    ? palette.danger
                    : palette.body,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Step 3: the thanks screen.
class ReportSentStep extends StatelessWidget {
  const ReportSentStep({
    super.key,
    required this.palette,
    required this.copy,
    required this.onDone,
  });

  final ReportPalette palette;
  final ReportCopy copy;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Center(
        child: AppSvgIcon(
          AppAssets.check,
          size: StoryPermissionDimens.icon,
          color: palette.success,
        ),
      ),
      SizedBox(height: AppSpacing.s16),
      AppText(
        context.l10n.reportSentTitle,
        style: context.text.stat,
        color: palette.title,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: AppSpacing.s8),
      AppText(
        copy.sentBody,
        style: context.text.bodySm,
        color: palette.body,
        textAlign: TextAlign.center,
      ),
      // TODO(story-plan T6): post adds Mute / Unfollow rows to the sent step
      SizedBox(height: AppSpacing.s24),
      PrimaryButton(
        label: context.l10n.reportDone,
        expand: true,
        buttonHeight: AuthButtonDimens.pillHeight,
        onPressed: onDone,
      ),
    ],
  );
}
