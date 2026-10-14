import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';

/// A dark card at the top of the screen for a few seconds ("Sharing with close friends"). It sits on the
/// root overlay, so it shows above a bottom sheet, where a snackbar would be hidden.
abstract final class VisibilityToast {
  static const _visibleFor = Duration(seconds: 4);

  static OverlayEntry? _current;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String title,
    String? body,
    String? icon,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _remove();
    final entry = OverlayEntry(
      builder: (_) => _ToastCard(title: title, body: body, icon: icon),
    );
    _current = entry;
    overlay.insert(entry);
    _timer = Timer(_visibleFor, _remove);
  }

  static void _remove() {
    _timer?.cancel();
    _timer = null;
    final entry = _current;
    _current = null;
    if (entry != null && entry.mounted) entry.remove();
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({required this.title, this.body, this.icon});

  final String title;
  final String? body;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Semantics(
              liveRegion: true,
              container: true,
              label: body == null ? title : '$title, $body',
              child: ExcludeSemantics(
                child: Container(
                  margin: EdgeInsets.all(AppSpacing.s16),
                  padding: EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: colors.storySheet,
                    borderRadius: BorderRadius.circular(
                      VisibilityDimens.noteRadius,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Container(
                          width: VisibilityDimens.tile,
                          height: VisibilityDimens.tile,
                          decoration: BoxDecoration(
                            color: colors.storySuccess,
                            borderRadius: BorderRadius.circular(
                              VisibilityDimens.tileRadius,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: AppSvgIcon(
                            icon!,
                            size: VisibilityDimens.tileIcon,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.s12),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              title,
                              style: context.text.name,
                              color: colors.storyOnDark,
                            ),
                            if (body != null)
                              AppText(
                                body!,
                                style: context.text.caption,
                                color: colors.storyOnDark.withValues(
                                  alpha: StoryOpacity.subtitle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
