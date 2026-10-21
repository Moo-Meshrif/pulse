import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/domain/entity/content_publish_line.dart';
import '../../../../../shared/content/domain/use_case/get_publish_line_use_case.dart';
import '../../dimens/home_dimens.dart';

/// The posts being sent, in the order they were shared, for the banner above the feed.
@injectable
class PostLineCubit extends BaseCubit<ContentPublishLine>
    with EventCubitMixin<ContentPublishLine> {
  PostLineCubit(this._events, GetPublishLineUseCase line)
    : super(line(ContentKind.post));

  final EventBus _events;

  @override
  EventBus get events => _events;

  Timer? _hide;

  /// Follows the line; a post already being sent shows from the first frame.
  void start() {
    listenTo<ContentPublishLine>((line) {
      if (line.kind == ContentKind.post) _show(line);
    });
    _hideWhenDone(state);
  }

  void _show(ContentPublishLine line) {
    _hide?.cancel();
    emit(line);
    _hideWhenDone(line);
  }

  /// Once every post is out the line shows "All posted" for a moment, then goes away.
  void _hideWhenDone(ContentPublishLine line) {
    if (!line.isAllDone) return;
    _hide = Timer(
      HomeDimens.publishDoneStay,
      () => emit(const ContentPublishLine(ContentKind.post, [])),
    );
  }

  @override
  Future<void> close() {
    _hide?.cancel();
    return super.close();
  }
}
