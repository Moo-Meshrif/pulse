import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/notice_context.dart';
import '../cubit/post_likes/post_likes_cubit.dart';
import '../cubit/post_likes/post_likes_state.dart';
import '../view/post_likes_view.dart';

/// Who liked a post (docs/specs/post/screens/s15-post-page.md, S16): provides the cubit and shows the
/// notice when a follow or a refresh did not go through.
class PostLikesScreen extends StatelessWidget {
  const PostLikesScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<PostLikesCubit>(param1: postId)..load(),
    child: BlocListener<PostLikesCubit, PostLikesState>(
      listenWhen: (before, now) =>
          now.failure != null && before.failure != now.failure,
      listener: (context, state) => context.showFailure(state.failure),
      child: const PostLikesView(),
    ),
  );
}
