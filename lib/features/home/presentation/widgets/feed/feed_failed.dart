import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../cubit/feed/feed_cubit.dart';
import 'feed_message_page.dart';

/// The first load failed: the same page with a way to try again.
class FeedFailed extends StatelessWidget {
  const FeedFailed({super.key, required this.failure});

  final Failure? failure;

  bool get _isOffline => failure is NetworkFailure;

  @override
  Widget build(BuildContext context) {
    final retry = context.read<FeedCubit>().load;
    return FeedMessagePage(
      body: _isOffline
          ? AppEmpty.offline(onRetry: retry)
          : AppEmpty.failed(onRetry: retry),
    );
  }
}
