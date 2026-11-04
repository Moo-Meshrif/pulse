import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/notice_context.dart';
import '../../../../core/notice/notices.dart';
import '../../../follow/data/enums/follow_status.dart';
import '../cubit/author_prefs/author_prefs_cubit.dart';
import '../cubit/other_profile/other_profile_cubit.dart';
import '../cubit/other_profile/other_profile_state.dart';
import '../view/other_profile_view.dart';

class OtherProfileScreen extends StatelessWidget {
  const OtherProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => getIt<OtherProfileCubit>(param1: userId)..load(),
      ),
      BlocProvider(create: (_) => getIt<AuthorPrefsCubit>(param1: userId)),
    ],
    child: BlocListener<OtherProfileCubit, OtherProfileState>(
      listenWhen: (a, b) =>
          a.failure != b.failure ||
          (!a.requestSent && b.requestSent) ||
          (b.page != null && (a.page == null || a.follow != b.follow)),
      listener: (context, state) {
        final onFollowChanged = ModalRoute.of(context)?.settings.arguments;
        if (state.page != null && onFollowChanged is ValueChanged<FollowStatus>) {
          onFollowChanged(state.follow);
        }
        if (state.failure != null) context.showFailure(state.failure);
        if (state.requestSent) {
          Notices.success(
            context.l10n.otherRequestSent,
            body: context.l10n.otherRequestSentHint,
          );
        }
      },
      child: const OtherProfileView(),
    ),
  );
}
