import 'package:flutter/material.dart';

import '../theme/app_breakpoints.dart';
import '../theme/app_colors.dart';

extension ThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

extension WindowSizeContext on BuildContext {
  /// The window's size class. Reads `MediaQuery.sizeOf`, so it rebuilds only when the size changes.
  WindowSize get windowSize => WindowSize.of(MediaQuery.sizeOf(this).width);
}
