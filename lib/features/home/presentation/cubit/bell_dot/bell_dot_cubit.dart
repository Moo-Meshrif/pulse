import 'package:injectable/injectable.dart';

import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../activity/domain/use_case/get_unread_activity_count_use_case.dart';
import '../../../../post/domain/event/feed_refresh_requested.dart';

/// Whether the bell in the header shows its red dot: unread notifications or waiting follow requests.
@injectable
class BellDotCubit extends BaseCubit<bool> with EventCubitMixin<bool> {
  BellDotCubit(this._unreadCount, this._events) : super(false);

  final GetUnreadActivityCountUseCase _unreadCount;
  final EventBus _events;

  @override
  EventBus get events => _events;

  /// Reads the count, and again whenever Home is refreshed.
  Future<void> start() {
    listenTo<FeedRefreshRequested>((_) => load());
    return load();
  }

  /// A count that cannot be read leaves the dot as it is.
  Future<void> load() => run(
    _unreadCount.call,
    onSuccess: (count) => count > 0,
    onFailure: (_) => null,
  );
}
