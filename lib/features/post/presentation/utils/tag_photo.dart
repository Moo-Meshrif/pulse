import '../../../../core/utils/equatable.dart';

/// One photo or video of the post being written, for the Tag in photo page. [position] is its place in the
/// post's media. A photo is drawn from [filePath] (picked now) or [url] (already on the post).
class TagPhoto extends Equatable {
  final int position;
  final bool isVideo;
  final String? filePath;
  final String? url;
  final double aspect;

  const TagPhoto({
    required this.position,
    required this.isVideo,
    this.filePath,
    this.url,
    this.aspect = 1,
  });

  @override
  List<Object?> get props => [position, isVideo, filePath, url, aspect];
}
