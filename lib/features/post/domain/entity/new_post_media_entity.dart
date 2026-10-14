import '../../../../core/utils/equatable.dart';

/// A photo or video picked for a new post, already resized and measured.
class NewPostMediaEntity extends Equatable {
  /// The file on this device.
  final String filePath;
  final bool isVideo;
  final int width;
  final int height;

  /// Videos only.
  final int? durationMs;
  final String? blurhash;

  const NewPostMediaEntity({
    required this.filePath,
    required this.isVideo,
    required this.width,
    required this.height,
    this.durationMs,
    this.blurhash,
  });

  @override
  List<Object?> get props => [
    filePath,
    isVideo,
    width,
    height,
    durationMs,
    blurhash,
  ];
}
