import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// The white search pill: a ring in `primary` while it has focus and a clear button once it has text.
/// It keeps its own controller and focus node; [onChanged] reports every change, clearing included.
class LocationSearchField extends StatefulWidget {
  const LocationSearchField({
    super.key,
    required this.onChanged,
    this.autofocus = false,
    this.enabled = true,
  });

  final ValueChanged<String> onChanged;
  final bool autofocus;

  /// False while offline: the field greys out and takes no text.
  final bool enabled;

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
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
    final hint = context.l10n.locationSearchHint;
    final textStyle = context.text.body.copyWith(
      textBaseline: TextBaseline
          .alphabetic, // TextField asserts on it when inherit is false
    );
    return Container(
      height: LocationDimens.searchHeight,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(LocationDimens.searchRadius),
        border: Border.all(
          color: _focus.hasFocus ? colors.primary : Colors.transparent,
          width: LocationDimens.focusRingWidth,
        ),
      ),
      child: Row(
        children: [
          AppSvgIcon(
            AppAssets.search,
            size: LocationDimens.searchIcon,
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
              cursorColor: colors.primary,
              style: textStyle.copyWith(color: colors.textPrimary),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: textStyle.copyWith(color: colors.textSecondary),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty) _ClearButton(onTap: _clear),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: context.l10n.locationClearSearch,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: LocationDimens.clearTapTarget,
          child: Center(
            child: Container(
              width: LocationDimens.clearButton,
              height: LocationDimens.clearButton,
              decoration: BoxDecoration(
                color: colors.border,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppSvgIcon(
                AppAssets.close,
                size: LocationDimens.clearIcon,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
