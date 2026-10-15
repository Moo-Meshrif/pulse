import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/tag_in_photo_cubit.dart';
import '../cubit/tag_in_photo_state.dart';
import '../utils/tag_people_args.dart';
import '../view/tag_in_photo_view.dart';
import '../widgets/tag_in_photo/tag_person_picker_sheet.dart';

/// `/create/post/tag-in-photo`: put each chosen person on a photo (docs/specs/post/screens/
/// s7-tag-in-photo.md). Done goes back with the `List<TagChoice>` and their spots; the back arrow asks first
/// when something changed.
class TagInPhotoScreen extends StatelessWidget {
  const TagInPhotoScreen({super.key, required this.args});

  final TagPeopleArgs args;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<TagInPhotoCubit>(param1: args),
    child: Builder(
      builder: (context) => BlocListener<TagInPhotoCubit, TagInPhotoState>(
        listenWhen: (before, now) => !before.hasPending && now.hasPending,
        listener: _pickPerson,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _closeAskingFirst(context);
          },
          child: TagInPhotoView(
            onBack: () => _closeAskingFirst(context),
            onDone: () => AppNavigator.back(
              context,
              context.read<TagInPhotoCubit>().state.chosen,
            ),
          ),
        ),
      ),
    ),
  );

  /// The tapped spot is marked: ask who goes there. A dismissed list takes the mark off again.
  Future<void> _pickPerson(BuildContext context, TagInPhotoState state) async {
    final cubit = context.read<TagInPhotoCubit>();
    final position = state.photo.position;
    final id = await TagPersonPickerSheet.show(
      context,
      people: [
        for (final choice in state.chosen)
          if (choice.mediaPosition != position) choice,
      ],
    );
    if (id == null) {
      cubit.cancelPending();
    } else {
      cubit.place(id);
    }
  }

  Future<void> _closeAskingFirst(BuildContext context) async {
    if (!context.read<TagInPhotoCubit>().hasChanges) {
      AppNavigator.back(context);
      return;
    }
    final l10n = context.l10n;
    final discard = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.trash,
      title: l10n.editPostDiscardTitle,
      message: l10n.editPostDiscardBody,
      confirmLabel: l10n.newPostDiscard,
      cancelLabel: l10n.newPostKeepEditing,
    );
    if (discard == true && context.mounted) AppNavigator.back(context);
  }
}
