import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/state/base_cubit.dart';
import '../../../activity/domain/use_case/get_unread_activity_count_use_case.dart';
import '../../../post/domain/use_case/watch_feed_refresh_requests_use_case.dart';

/// Whether the bell in the header shows its red dot: unread notifications or waiting follow requests.
@injectable
class BellDotCubit extends BaseCubit<bool> {
  BellDotCubit(this._unreadCount, this._refreshRequests) : super(false);

  final GetUnreadActivityCountUseCase _unreadCount;
  final WatchFeedRefreshRequestsUseCase _refreshRequests;
  StreamSubscription<void>? _requests;

  /// Reads the count, and again whenever Home is refreshed.
  Future<void> start() {
    _requests ??= _refreshRequests().listen((_) => load());
    return load();
  }

  /// A count that cannot be read leaves the dot as it is.
  Future<void> load() => run(
    _unreadCount.call,
    onSuccess: (count) => count > 0,
    onFailure: (_) => null,
  );

  @override
  Future<void> close() async {
    await _requests?.cancel();
    return super.close();
  }
}
