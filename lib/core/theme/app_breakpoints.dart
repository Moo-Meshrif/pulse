/// Window size classes (Material 3). The single breakpoint source: features never compare raw
/// widths, they switch on `context.windowSize`.
enum WindowSize {
  /// < 600: phones in portrait.
  compact,

  /// 600-839: large phones in landscape, small tablets, foldables.
  medium,

  /// >= 840: tablets in landscape, desktop, web.
  expanded;

  static WindowSize of(double width) => switch (width) {
    < 600 => compact,
    < 840 => medium,
    _ => expanded,
  };
}

/// Layout limits shared by every screen.
abstract final class AppBreakpoints {
  /// Readable line length: content wider than this is centered with margins.
  static const maxContentWidth = 840.0;
}
