import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../profile/data/model/interest_model.dart';
import '../cubit/sign_up_cubit.dart';
import '../cubit/sign_up_state.dart';
import '../utils/enums/load_status.dart';
import '../widgets/auth_header.dart';
import '../widgets/skeleton_pill.dart';

/// Sign-up step 5, Interests (docs/specs/auth/screens/s7-signup-interests.md): the topics as chips, with
/// skeletons while they load and a message with Retry when they could not be loaded.
class SignUpInterestsView extends StatelessWidget {
  const SignUpInterestsView({super.key});

  static const _skeletonCount = 10;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SignUpCubit>();
    return PinnedBottomCta(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.formSide,
          AuthDimens.signUpTopGap,
          AppSpacing.formSide,
          AppSpacing.s24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(
              title: l10n.interestsTitle,
              subtitle: l10n.interestsSubtitle,
            ),
            SizedBox(height: AuthDimens.signUpTopGap),
            BlocBuilder<SignUpCubit, SignUpState>(
              buildWhen: _interestsChanged,
              builder: (context, state) => switch (state.interestsStatus) {
                LoadStatus.failed => _LoadError(
                  message: l10n.interestsError,
                  onRetry: cubit.retryInterests,
                ),
                LoadStatus.loaded => _chips(context, state),
                _ => _skeletons(),
              },
            ),
          ],
        ),
      ),
      cta: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocSelector<SignUpCubit, SignUpState, int>(
            selector: (state) => state.selectedInterests.length,
            builder: (context, selected) => _selectedCount(context, selected),
          ),
          BlocSelector<SignUpCubit, SignUpState, bool>(
            selector: (state) => state.loading,
            builder: (context, loading) => PrimaryButton(
              label: l10n.continueButton,
              expand: true,
              loading: loading,
              onPressed: loading ? null : cubit.submitInterests,
            ),
          ),
        ],
      ),
    );
  }

  bool _interestsChanged(SignUpState before, SignUpState state) =>
      before.interestsStatus != state.interestsStatus ||
      before.interests != state.interests ||
      before.selectedInterests != state.selectedInterests;

  /// "3 selected" above the button, hidden while nothing is selected.
  Widget _selectedCount(BuildContext context, int selected) {
    if (selected == 0) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s12),
      child: AppText(
        context.l10n.selectedCount(selected),
        style: context.text.bodySm,
        color: context.appColors.textSecondary,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _chips(BuildContext context, SignUpState state) {
    final language = Localizations.localeOf(context).languageCode;
    final cubit = context.read<SignUpCubit>();
    return Wrap(
      spacing: AuthDimens.chipWrapSpacing,
      runSpacing: AuthDimens.interestChipRunSpacing,
      children: [
        for (final InterestModel interest in state.interests)
          if (interest.id != null)
            SelectableChip(
              label: interest.nameFor(language) ?? '',
              selected: state.selectedInterests.contains(interest.id),
              height: AuthDimens.interestChipHeight,
              onTap: () => cubit.interestToggled(interest.id!),
            ),
      ],
    );
  }

  Widget _skeletons() => Wrap(
    spacing: AuthDimens.chipWrapSpacing,
    runSpacing: AuthDimens.interestChipRunSpacing,
    children: [
      for (var i = 0; i < _skeletonCount; i++)
        SkeletonPill(
          width: AuthDimens.interestSkeletonWidth + (i % 3) * AppSpacing.s16,
          height: AuthDimens.interestChipHeight,
        ),
    ],
  );
}

/// "Couldn't load …" with a Retry text button.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      AppText(
        message,
        style: context.text.subtitle,
        color: context.appColors.textSecondary,
        textAlign: TextAlign.center,
      ),
      TextButton(
        onPressed: onRetry,
        style: TextButton.styleFrom(
          minimumSize: const Size(AuthDimens.tapTarget, AuthDimens.tapTarget),
          foregroundColor: context.appColors.primary,
        ),
        child: AppText(
          context.l10n.retry,
          style: context.text.name,
          color: context.appColors.primary,
        ),
      ),
    ],
  );
}
