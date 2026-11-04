import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/notice_context.dart';
import '../../../../core/notice/notices.dart';
import '../cubit/blocked/blocked_cubit.dart';
import '../cubit/blocked/blocked_state.dart';
import '../view/blocked_view.dart';

/// `/settings/blocked` (docs/specs/profile/screens/s6-blocked-accounts.md): provides the cubit and shows
/// a failure or the "Unblocked @name" notice once.
class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<BlockedCubit>()..load(),
    child: MultiBlocListener(
      listeners: [
        BlocListener<BlockedCubit, BlockedState>(
          listenWhen: (before, now) =>
              now.failure != null && now.failure != before.failure,
          listener: (context, state) => context.showFailure(state.failure),
        ),
        BlocListener<BlockedCubit, BlockedState>(
          listenWhen: (before, now) =>
              now.unblockedUsername != null &&
              now.people.length < before.people.length,
          listener: (context, state) =>
              Notices.success(context.l10n.unblocked(state.unblockedUsername!)),
        ),
      ],
      child: const BlockedView(),
    ),
  );
}
