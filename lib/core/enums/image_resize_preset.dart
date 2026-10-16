/// How far a photo is shrunk before it goes out. [maxSide] is the longest side in pixels,
/// [quality] the JPEG quality.
enum ImageResizePreset {
  /// Instagram-like.
  standard(maxSide: 1080, quality: 80),
  high(maxSide: 1440, quality: 85),
  max(maxSide: 2048, quality: 85),

  /// A photo shown on the whole screen (a story): a 1080 x 1920 screen at full sharpness.
  fullScreen(maxSide: 1920, quality: 80);

  const ImageResizePreset({required this.maxSide, required this.quality});

  /// The preset the app uses; change it here to switch (there is no user setting).
  static const active = standard;

  final int maxSide;
  final int quality;
}
