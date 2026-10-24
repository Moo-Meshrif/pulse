import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import 'widgets.dart';

/// The white search pill (Add location, Tag people): a ring in `primary` while it has focus and a clear button once it has text.
/// It keeps its own controller and focus node; [onChanged] reports every change, clearing included.
class SearchPillField extends StatefulWidget {
  const SearchPillField({
    super.key,
    required this.onChanged,
    required this.hint,
    required this.clearLabel,
    this.autofocus = false,
    this.enabled = true,
  });

  final ValueChanged<String> onChanged;
  final String hint;

  /// Spoken by the clear button.
  final String clearLabel;
  final bool autofocus;

  /// False while offline: the field greys out and takes no text.
  final bool enabled;

  @override
  State<SearchPillField> createState() => _SearchPillFieldState();
}

class _SearchPillFieldState extends State<SearchPillField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuildForClearButton);
    _focus.addListener(_rebuildForRing);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _rebuildForClearButton() => setState(() {});

  void _rebuildForRing() => setState(() {});

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hint = widget.hint;
    final textStyle = context.text.body.copyWith(
      textBaseline: TextBaseline
          .alphabetic, // TextField asserts on it when inherit is false
    );
    return Container(
      height: SearchFieldDimens.height,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(SearchFieldDimens.radius),
        border: Border.all(
          color: _focus.hasFocus ? colors.primary : Colors.transparent,
          width: SearchFieldDimens.focusRingWidth,
        ),
      ),
      child: Row(
        children: [
          AppSvgIcon(
            AppAssets.search,
            size: SearchFieldDimens.icon,
            color: colors.textSecondary,
          ),
          SizedBox(width: AppSpacing.s12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: textStyle.copyWith(color: colors.textPrimary),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: textStyle.copyWith(color: colors.textSecondary),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            _ClearButton(onTap: _clear, label: widget.clearLabel),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: SearchFieldDimens.clearTapTarget,
          child: Center(
            child: Container(
              width: SearchFieldDimens.clearButton,
              height: SearchFieldDimens.clearButton,
              decoration: BoxDecoration(
                color: colors.border,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppSvgIcon(
                AppAssets.close,
                size: SearchFieldDimens.clearIcon,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
