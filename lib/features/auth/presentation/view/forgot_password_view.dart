import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../widgets/auth_back_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/icon_tile.dart';

/// Forgot password's UI (docs/specs/auth/screens/s2-forgot-password.md). The email controller and
/// focus node are local UI state; "Back to sign in" is pinned above the keyboard. The email field and
/// the button listen to the Cubit on their own, so typing rebuilds only them.
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _email = TextEditingController();
  final _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _cubit.emailLeft();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  ForgotPasswordCubit get _cubit => context.read<ForgotPasswordCubit>();

  bool _focusRequested(ForgotPasswordState before, ForgotPasswordState state) =>
      before.focusRequest != state.focusRequest;

  void _focusAndSelectEmail(BuildContext context, ForgotPasswordState state) {
    _emailFocus.requestFocus();
    _email.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _email.text.length,
    );
  }

  // The field only reads these two, so a keystroke rebuilds it only when one flips.
  bool _emailFieldChanged(
    ForgotPasswordState before,
    ForgotPasswordState state,
  ) =>
      before.loading != state.loading ||
      before.emailInvalidShown != state.emailInvalidShown;

  bool _submitButtonChanged(
    ForgotPasswordState before,
    ForgotPasswordState state,
  ) => before.loading != state.loading || before.canSubmit != state.canSubmit;

  void _goBackToSignIn() => AppNavigator.back(context);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: _focusRequested,
      listener: _focusAndSelectEmail,
      child: Scaffold(
        body: AppSafeArea(
          bottomSpace: AppSpacing.s24,
          child: ContentWidth(
            child: PinnedBottomCta(
              body: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        top: AppSpacing.headerSide,
                        start: AppSpacing.headerBackSide,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AuthBackButton(onPressed: _goBackToSignIn),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.formSide,
                        AuthDimens.forgotTileTopGap,
                        AppSpacing.formSide,
                        0,
                      ),
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthHeader(
                              leading: const Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: IconTile(icon: AppAssets.lock),
                              ),
                              title: l10n.forgotTitle,
                              subtitle: l10n.forgotSubtitle,
                            ),
                            SizedBox(height: AuthDimens.headerToFormGap),
                            BlocBuilder<
                              ForgotPasswordCubit,
                              ForgotPasswordState
                            >(
                              buildWhen: _emailFieldChanged,
                              builder: (context, state) => AppTextField(
                                label: l10n.emailLabel,
                                hint: l10n.emailHint,
                                controller: _email,
                                focusNode: _emailFocus,
                                forceLtr: true,
                                readOnly: state.loading,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.email],
                                errorText: state.emailInvalidShown
                                    ? l10n.errorInvalidEmail
                                    : null,
                                onChanged: _cubit.emailChanged,
                                onSubmitted: (_) => _cubit.submit(),
                              ),
                            ),
                            SizedBox(height: AuthDimens.formToButtonGap),
                            BlocBuilder<
                              ForgotPasswordCubit,
                              ForgotPasswordState
                            >(
                              buildWhen: _submitButtonChanged,
                              builder: (context, state) => PrimaryButton(
                                label: l10n.sendResetLink,
                                expand: true,
                                loading: state.loading,
                                onPressed: state.canSubmit
                                    ? _cubit.submit
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              cta: PillButton.outline(
                label: l10n.backToSignIn,
                onPressed: _goBackToSignIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
