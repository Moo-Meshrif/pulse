import '../../../../core/error/failures.dart';
import '../../../../core/utils/equatable.dart';
import '../../data/enums/content_kind.dart';

/// Where one item of a [ContentPublishLine] stands.
enum ContentLineState { waiting, sending, failed, done }

/// One post, short or story in the line of what is being sent.
final class ContentLineItem extends Equatable {
  const ContentLineItem({
    required this.id,
    required this.state,
    this.progress = 0,
    this.isEdit = false,
    this.failure,
    this.previewPath,
    this.previewUrl,
    this.previewCacheKey,
  });

  /// Names the item for Retry and Discard.
  final String id;
  final ContentLineState state;

  /// 0..1; 1 once done.
  final double progress;
  final bool isEdit;
  final Failure? failure;
  final String? previewPath;
  final String? previewUrl;
  final String? previewCacheKey;

  /// A failed item that can be sent again.
  bool get canRetry =>
      state == ContentLineState.failed && failure is! RejectedFailure;

  /// Failed only because the connection is down: it goes again by itself when the app is back.
  bool get isOffline =>
      state == ContentLineState.failed &&
      (failure is NetworkFailure || failure is TimeoutFailure);

  ContentLineItem done() => ContentLineItem(
    id: id,
    state: ContentLineState.done,
    progress: 1,
    isEdit: isEdit,
    previewPath: previewPath,
    previewUrl: previewUrl,
    previewCacheKey: previewCacheKey,
  );

  @override
  List<Object?> get props => [
    id,
    state,
    progress,
    isEdit,
    failure,
    previewPath,
    previewUrl,
    previewCacheKey,
  ];
}

/// Everything of [kind] in the line, in the order it was shared, with the finished ones kept for a
/// moment after the last one is out. Sent on the `EventBus` at every change; the status of the one going
/// out is `ContentPublishStatus`. Public: Home shows the posts' line above the feed.
final class ContentPublishLine extends Equatable {
  const ContentPublishLine(this.kind, this.items);

  final ContentKind kind;
  final List<ContentLineItem> items;

  bool get isEmpty => items.isEmpty;

  int get doneCount =>
      items.where((item) => item.state == ContentLineState.done).length;

  int get failedCount =>
      items.where((item) => item.state == ContentLineState.failed).length;

  /// Every item is done (the line is about to go away).
  bool get isAllDone => items.isNotEmpty && doneCount == items.length;

  /// How much of all the items is sent, 0..1.
  double get progress {
    if (items.isEmpty) return 0;
    final sum = items.fold<double>(0, (sum, item) => sum + item.progress);
    return sum / items.length;
  }

  @override
  List<Object?> get props => [kind, items];
}
