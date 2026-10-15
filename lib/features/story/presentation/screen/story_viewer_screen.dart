import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_navigator.dart';
import '../../domain/entity/story_rail_item_entity.dart';
import '../cubit/story_viewer_cubit.dart';
import '../cubit/story_viewer_state.dart';
import '../view/story_viewer_view.dart';

/// `/story/:authorId`: one person's stories, then the next people of the rail
/// (docs/specs/story/screens/s1-story-viewer.md). Full screen over the shell.
class StoryViewerScreen extends StatelessWidget {
  const StoryViewerScreen({super.key, required this.authorId, this.person});

  final String authorId;
  final StoryRailItemEntity? person;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<StoryViewerCubit>()..load(authorId),
    child: BlocListener<StoryViewerCubit, StoryViewerState>(
      listenWhen: (before, now) => !before.isFinished && now.isFinished,
      listener: (context, _) => AppNavigator.back(context),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: context.appColors.black,
          resizeToAvoidBottomInset: false,
          body: StoryViewerView(authorId: authorId, person: person),
        ),
      ),
    ),
  );
}
