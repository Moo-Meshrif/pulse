import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/notice_context.dart';
import '../../../../core/router/app_navigator.dart';
import '../../data/enums/audience_list.dart';
import '../cubit/audience_list_cubit.dart';
import '../cubit/audience_list_state.dart';
import '../view/audience_list_view.dart';

/// `/audience/close-friends` and `/audience/hidden`: pick people from your followers
/// (docs/specs/story/screenshots/stories-board-v3.png, panel 12). Done saves and pops `true`.
class AudienceListScreen extends StatelessWidget {
  const AudienceListScreen({super.key, required this.list});

  final AudienceList list;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AudienceListCubit>(param1: list)..start(),
    child: BlocListener<AudienceListCubit, AudienceListState>(
      listenWhen: (before, now) =>
          (!before.isSaved && now.isSaved) ||
          (before.failure == null && now.failure != null),
      listener: (context, state) {
        if (state.isSaved) {
          AppNavigator.back(context, true);
          return;
        }
        context.showFailure(state.failure);
        context.read<AudienceListCubit>().clearFailure();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: context.appColors.textPrimary,
          body: AudienceListView(list: list),
        ),
      ),
    ),
  );
}
