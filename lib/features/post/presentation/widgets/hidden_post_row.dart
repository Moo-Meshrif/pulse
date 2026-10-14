import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// What a post becomes after "Not interested" (docs/specs/post/screens/s2-post-options.md, panel 5): a row
/// that grows in over [PostMotion.hiddenCollapse] with an Undo pill for [PostMotion.undoWindow]. When the
/// window ends the pill goes and the row stays until the next refresh.
class HiddenPostRow extends StatefulWidget {
  const HiddenPostRow({super.key, required this.onUndo});

  final VoidCallback onUndo;

  @override
  State<HiddenPostRow> createState() => _HiddenPostRowState();
}

class _HiddenPostRowState extends State<HiddenPostRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _size = AnimationController(
    vsync: this,
    duration: PostMotion.hiddenCollapse,
  )..forward();
  late final Timer _undoWindow;
  bool _canUndo = true;

  @override
  void initState() {
    super.initState();
    _undoWindow = Timer(PostMotion.undoWindow, _closeUndoWindow);
  }

  @override
  void dispose() {
    _undoWindow.cancel();
    _size.dispose();
    super.dispose();
  }

  void _closeUndoWindow() {
    if (mounted) setState(() => _canUndo = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: _size, curve: Curves.easeOut),
      alignment: AlignmentDirectional.topStart,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(PostCardDimens.radius),
        ),
        child: Row(
          children: [
            AppSvgIcon(
              AppAssets.eyeOff,
              size: PostOptionsDimens.rowIcon,
              color: colors.textSecondary,
            ),
            SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.postHidden,
                    style: context.text.name,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    l10n.postHiddenHint,
                    style: context.text.caption,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            if (_canUndo) ...[
              SizedBox(width: AppSpacing.s12),
              _UndoPill(onTap: widget.onUndo),
            ],
          ],
        ),
      ),
    );
  }
}

class _UndoPill extends StatelessWidget {
  const _UndoPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = context.l10n.undo;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      child: Material(
        color: colors.primarySoft,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AuthButtonDimens.pillHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Center(
                widthFactor: 1,
                child: AppText(
                  label,
                  style: context.text.action,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
