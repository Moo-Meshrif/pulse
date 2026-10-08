import 'package:flutter/material.dart';

/// The app's one circular progress indicator: a [size] square with a [strokeWidth] ring in [color].
/// `AppLoadingView` and the loading state of `PrimaryButton` both use it, so every spinner looks the same.
class AppSpinner extends StatelessWidget {
  const AppSpinner({
    super.key,
    required this.size,
    required this.strokeWidth,
    required this.color,
    this.trackColor,
    this.semanticsLabel,
  });

  final double size;
  final double strokeWidth;
  final Color color;

  /// The ring behind the arc (the splash draws a grey one); none by default.
  final Color? trackColor;

  /// What a screen reader says; null when the spinner sits inside something already labelled.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CircularProgressIndicator(
      strokeWidth: strokeWidth,
      color: color,
      backgroundColor: trackColor,
      semanticsLabel: semanticsLabel,
    ),
  );
}
