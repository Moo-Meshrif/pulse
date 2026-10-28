import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/personal_info/personal_info_cubit.dart';
import '../cubit/personal_info/personal_info_state.dart';
import '../widgets/personal_info_form.dart';

/// Personal info: the edit form of the signed-in user's profile, Save pinned at the bottom.
class PersonalInfoView extends StatelessWidget {
  const PersonalInfoView({super.key});

  Future<void> _close(BuildContext context) async {
    final l10n = context.l10n;
    final discard = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.trash,
      title: l10n.editPostDiscardTitle,
      message: l10n.personalInfoDiscardBody,
      confirmLabel: l10n.newPostDiscard,
      cancelLabel: l10n.keepEditing,
    );
    if (discard == true && context.mounted) AppNavigator.back(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PersonalInfoCubit>();
    return BlocSelector<PersonalInfoCubit, PersonalInfoState, bool>(
      selector: (state) => state.isDirty && !state.saved,
      builder: (context, dirty) => PopScope(
        canPop: !dirty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _close(context);
        },
        child: AppPage(
          backgroundColor: context.appColors.background,
          title: l10n.personalInfoTitle,
          onBack: () => dirty ? _close(context) : AppNavigator.back(context),
          child: BlocBuilder<PersonalInfoCubit, PersonalInfoState>(
            buildWhen: (before, now) =>
                before.isLoading != now.isLoading ||
                before.loadFailure != now.loadFailure,
            builder: (context, state) {
              if (state.isLoading) return const AppLoadingView();
              if (state.loadFailure != null) {
                return AppEmpty.failed(onRetry: cubit.load);
              }
              return const PersonalInfoForm();
            },
          ),
        ),
      ),
    );
  }
}
