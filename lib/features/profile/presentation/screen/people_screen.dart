import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/notice_context.dart';
import '../../data/enums/people_kind.dart';
import '../cubit/people/people_cubit.dart';
import '../cubit/people/people_state.dart';
import '../view/people_view.dart';

/// Followers, Following or "Followed by" of one person (docs/specs/profile/screens/s13-people-list.md):
/// provides the cubit and shows the notice when a follow or a refresh did not go through.
class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key, required this.kind, required this.userId});

  final PeopleKind kind;
  final String userId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<PeopleCubit>(param1: kind, param2: userId)..load(),
    child: BlocListener<PeopleCubit, PeopleState>(
      listenWhen: (before, now) =>
          now.failure != null && before.failure != now.failure,
      listener: (context, state) => context.showFailure(state.failure),
      child: PeopleView(kind: kind),
    ),
  );
}
