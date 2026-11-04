import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/model/blocked_person_model.dart';
import '../cubit/blocked/blocked_cubit.dart';
import '../cubit/blocked/blocked_state.dart';

/// A blocked person: avatar, name, "@username · Blocked 2 weeks ago" and the Unblock pill. The row opens
/// their profile (it shows the blocked card there).
class BlockedPersonTile extends StatelessWidget {
  const BlockedPersonTile({super.key, required this.person});

  final BlockedPersonModel person;

  @override
  Widget build(BuildContext context) {
    final id = person.id;
    final l10n = context.l10n;
    final blockedAt = person.blockedAt;
    final username = person.username ?? '';
    return PersonRow(
      userId: id ?? '',
      name: person.displayName,
      subtitle: blockedAt == null
          ? '@$username'
          : l10n.blockedAgo(username, timeAgo(l10n, blockedAt, clock.now())),
      avatarUrl: person.avatarUrl,
      isVerified: person.isVerified ?? false,
      onTap: id == null
          ? null
          : () => AppNavigator.push<void>(context, AppRoutes.profileOf(id)),
      trailing: BlocSelector<BlockedCubit, BlockedState, bool>(
        selector: (state) => state.unblocking.contains(id),
        builder: (context, busy) => OutlinePillButton(
          label: l10n.unblock,
          onPressed: busy
              ? null
              : () => context.read<BlockedCubit>().unblock(person),
        ),
      ),
    );
  }
}
