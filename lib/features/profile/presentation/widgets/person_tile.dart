import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../follow/data/enums/follow_status.dart';
import '../../data/model/person_model.dart';
import '../cubit/people/people_cubit.dart';

/// A person in the list: avatar, name, @username and the Follow pill (none on your own row).
class PersonTile extends StatelessWidget {
  const PersonTile({super.key, required this.person, required this.isMe});

  final PersonModel person;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final id = person.id;
    final l10n = context.l10n;
    final name = person.displayName;
    final status = person.followStatus ?? FollowStatus.none;
    return PersonRow(
      userId: id ?? '',
      name: name,
      subtitle: '@${person.username ?? ''}',
      avatarUrl: person.avatarUrl,
      isVerified: person.isVerified ?? false,
      // Your own row opens the Profile tab, which is already yours.
      onTap: id == null || isMe
          ? null
          : () => AppNavigator.push<void>(context, AppRoutes.profileOf(id)),
      trailing: isMe
          ? null
          : Semantics(
              label: switch (status) {
                FollowStatus.accepted => l10n.unfollowPerson(name),
                FollowStatus.pending => l10n.cancelRequestPerson(name),
                FollowStatus.none => l10n.followPerson(name),
              },
              child: OutlinePillButton(
                label: switch (status) {
                  FollowStatus.accepted => l10n.following,
                  FollowStatus.pending => l10n.requested,
                  FollowStatus.none => l10n.follow,
                },
                onPressed: () =>
                    context.read<PeopleCubit>().toggleFollow(person),
              ),
            ),
    );
  }
}
