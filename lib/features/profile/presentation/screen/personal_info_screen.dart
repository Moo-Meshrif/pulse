import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/notice_context.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../cubit/personal_info/personal_info_cubit.dart';
import '../cubit/personal_info/personal_info_state.dart';
import '../view/personal_info_view.dart';

/// `/settings/personal-info` (docs/specs/profile/screens/s3-personal-info.md): provides the cubit, shows
/// a failed save once and leaves with a notice once the profile is saved.
class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<PersonalInfoCubit>()..load(),
    child: BlocListener<PersonalInfoCubit, PersonalInfoState>(
      listenWhen: (before, now) =>
          (now.saved && !before.saved) ||
          (now.failure != null && now.failure != before.failure),
      listener: (context, state) {
        if (!state.saved) return context.showFailure(state.failure);
        Notices.success(context.l10n.personalInfoSaved);
        AppNavigator.back(context);
      },
      child: const PersonalInfoView(),
    ),
  );
}
