import '../app_scale.dart';

/// The page loaders (core/widgets/app_loading_view.dart, the "Page loading" board). Line widths; the
/// line's height follows its 184 x 88 frame.
abstract final class LoadingDimens {
  static double get pageWidth => AppScale.scale(100);
  static double get refreshWidth => AppScale.scale(56);
  static double get loadMoreWidth => AppScale.scale(44);
  static double get refreshBand => AppScale.scale(64);
  static double get loadMoreBand => AppScale.scale(72);
  static double get labelGap => AppScale.scale(16);

  /// The "all caught up" band at the end of a paged list.
  static double get endBand => AppScale.scale(48);
}

/// The loading overlay (core/widgets/loading_overlay/): a frosted scrim and a heartbeat line (a Lottie
/// animation that loops on its own, 1600 ms).
abstract final class OverlayDimens {
  static double get lineWidth => AppScale.scale(120);
  static double get labelGap => AppScale.scale(18);
  static double get progressGap => AppScale.scale(14);
  static double get progressTrackWidth => AppScale.scale(140);
  static double get progressTrackHeight => AppScale.scale(3);
  static double get progressTrackRadius => AppScale.scale(2);
  static double get percentGap => AppScale.scale(10);
  static double get percentWidth => AppScale.scale(34);
  static double get rise => AppScale.scale(8);
  static const double blur = 20; // unscaled: blur sigma
  static const Duration enter = Duration(milliseconds: 220);
  static const Duration exit = Duration(milliseconds: 160);
}

/// The empty / failed page (core/widgets/app_empty/, the "Empty and failed" board).
abstract final class AppEmptyDimens {
  static double get icon => AppScale.scale(72);
  static double get iconToTitleGap => AppScale.scale(24);
  static double get titleToBodyGap => AppScale.scale(10);
  static double get bodyToActionsGap => AppScale.scale(28);
  static double get bodyMaxWidth => AppScale.scale(300);
  static double get actionMaxWidth => AppScale.scale(280);
  static double get primaryHeight => AppScale.scale(52);
  static const double linkHeight = 44; // tap target: fixed
  static double get side => AppScale.scale(32);
  static double get rise => AppScale.scale(12);
  static double get float => AppScale.scale(3);
  static const Duration enter = Duration(milliseconds: 280);
  static const Duration floatLoop = Duration(
    milliseconds: 1600,
  ); // one way; a full cycle is 3.2 s
}
