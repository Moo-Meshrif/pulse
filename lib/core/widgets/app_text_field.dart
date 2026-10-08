import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../extensions/l10n.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';

/// The app's form field (docs/specs/auth/02-components.md C3). [forceLtr] keeps email, username and phone
/// text left-to-right in Arabic.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.required = false,
    this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.errorText,
    this.helperText,
    this.isPassword = false,
    this.prefixText,
    this.forceLtr = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.minLines,
    this.maxLines = 1,
    this.counterMax,
    this.inputFormatters,
  }) : assert(
         counterMax == null || controller != null,
         'The counter reads the controller',
       );

  final String label;
  final bool required;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  /// Replaces [helperText] and turns the border `danger`.
  final String? errorText;
  final String? helperText;
  final bool isPassword;

  /// Shown before the text, e.g. "@".
  final String? prefixText;
  final bool forceLtr;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final int? minLines;
  final int? maxLines;

  /// Blocks input at this length and shows "length/max" at the end of the label row.
  final int? counterMax;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasError = widget.errorText != null;

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: color, width: width),
    );

    final field = Semantics(
      label: widget.label,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        minLines: widget.minLines,
        maxLines: widget.isPassword ? 1 : widget.maxLines,
        obscureText: widget.isPassword && _obscured,
        autocorrect: !widget.isPassword && !widget.forceLtr,
        enableSuggestions: !widget.isPassword && !widget.forceLtr,
        textDirection: widget.forceLtr ? TextDirection.ltr : null,
        style: context.text.body.copyWith(
          color: colors.textPrimary,
          textBaseline: TextBaseline
              .alphabetic, // TextField asserts on it when inherit is false
        ),
        cursorColor: colors.primary,
        inputFormatters: [
          ...?widget.inputFormatters,
          if (widget.counterMax != null)
            LengthLimitingTextInputFormatter(widget.counterMax),
        ],
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: context.text.body.copyWith(
            color: colors.textSecondary,
            textBaseline: TextBaseline.alphabetic,
          ),
          filled: true,
          fillColor: colors.surface,
          contentPadding: AuthDimens.inputPadding,
          prefix: widget.prefixText == null
              ? null
              : AppText(
                  widget.prefixText!,
                  style: context.text.body,
                  color: colors.textSecondary,
                ),
          suffixIcon: widget.isPassword ? _eyeButton(context) : null,
          suffixIconConstraints: BoxConstraints(
            minWidth: AuthDimens.eyeTapTarget,
            minHeight: AuthDimens.eyeTapTarget,
          ),
          enabledBorder: border(
            hasError ? colors.danger : colors.border,
            hasError
                ? AuthDimens.inputActiveBorderWidth
                : AuthDimens.inputBorderWidth,
          ),
          disabledBorder: border(colors.border, AuthDimens.inputBorderWidth),
          focusedBorder: border(
            hasError ? colors.danger : colors.primary,
            AuthDimens.inputActiveBorderWidth,
          ),
          border: border(colors.border, AuthDimens.inputBorderWidth),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _label(context)),
            if (widget.counterMax != null) _counter(context),
          ],
        ),
        SizedBox(height: AppSpacing.labelGap),
        field,
        if (hasError || widget.helperText != null) ...[
          SizedBox(height: AppSpacing.labelGap),
          AppText(
            widget.errorText ?? widget.helperText!,
            style: context.text.caption,
            color: hasError ? colors.danger : colors.textSecondary,
          ),
        ],
      ],
    );
  }

  Widget _label(BuildContext context) {
    final colors = context.appColors;
    final style = context.text.label.copyWith(color: colors.textPrimary);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: widget.label),
          if (widget.required)
            TextSpan(
              text: ' *',
              style: style.copyWith(color: colors.danger),
            ),
        ],
      ),
    );
  }

  Widget _counter(BuildContext context) => ValueListenableBuilder(
    valueListenable: widget.controller!,
    builder: (context, value, _) => AppText(
      '${value.text.characters.length}/${widget.counterMax}',
      style: context.text.caption,
      color: context.appColors.textSecondary,
    ),
  );

  Widget _eyeButton(BuildContext context) => Semantics(
    button: true,
    label: _obscured ? context.l10n.showPassword : context.l10n.hidePassword,
    excludeSemantics: true,
    child: InkResponse(
      onTap: () => setState(() => _obscured = !_obscured),
      radius: AuthDimens.eyeTapTarget / 2,
      child: SizedBox.square(
        dimension: AuthDimens.eyeTapTarget,
        child: Center(
          child: AppSvgIcon(
            _obscured ? AppAssets.eye : AppAssets.eyeOff,
            size: AuthDimens.eyeIcon,
            color: context.appColors.textSecondary,
          ),
        ),
      ),
    ),
  );
}
