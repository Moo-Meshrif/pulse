import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_navigator.dart';
import '../cubit/add_location_cubit.dart';
import '../cubit/add_location_state.dart';
import '../view/add_location_view.dart';

/// `/create/post/location`: choose the place name saved on the post (docs/specs/post/screens/
/// s3-add-location.md). Goes back with a `LocationChoice` when a place is picked or removed, with nothing
/// when the back arrow is used. [current] is the place already on the post.
class AddLocationScreen extends StatelessWidget {
  const AddLocationScreen({super.key, this.current});

  final String? current;

  @override
  Widget build(BuildContext context) {
    // Read here: `create` runs once and cannot depend on the locale.
    final languageCode = Localizations.localeOf(context).languageCode;
    return BlocProvider(
      create: (_) =>
          getIt<AddLocationCubit>(param1: current)..start(languageCode),
      child: BlocListener<AddLocationCubit, AddLocationState>(
        listenWhen: (before, now) =>
            before.result == null && now.result != null,
        listener: _goBackWithChoice,
        child: const AddLocationView(),
      ),
    );
  }

  void _goBackWithChoice(BuildContext context, AddLocationState state) =>
      AppNavigator.back(context, state.result);
}
