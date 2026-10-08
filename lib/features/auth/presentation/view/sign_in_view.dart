import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/sign_in_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_switch_link.dart';
import '../widgets/forgot_password_link.dart';
import '../widgets/or_divider.dart';
import '../widgets/social_buttons_row.dart';

/// Sign in's pure UI (docs/specs/auth/screens/s1-signin.md). The text controllers are local UI state;
/// everything else comes from [state] and the callbacks. Fields are read-only while a request runs.
class SignInView extends StatefulWidget {
  const SignInView({
    super.key,
    required this.state,
    required this.onIdentifierChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onCreateAccount,
  });

  final SignInState state;
  final ValueChanged<String> onIdentifierChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = widget.state;
    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.formSide,
                  ),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: AuthDimens.signInTopGap),
                        AuthHeader(
                          leading: const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: LogoTile(),
                          ),
                          title: l10n.signInTitle,
                          subtitle: l10n.signInSubtitle,
                        ),
                        SizedBox(height: AuthDimens.signInFormGap),
                        AppTextField(
                          label: l10n.identifierLabel,
                          hint: l10n.emailHint,
                          controller: _identifier,
                          forceLtr: true,
                          readOnly: state.loading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],
                          errorText: state.identifierMissing
                              ? l10n.errorIdentifierRequired
                              : null,
                          onChanged: widget.onIdentifierChanged,
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                        ),
                        SizedBox(height: AppSpacing.fieldGap),
                        AppTextField(
                          label: l10n.passwordLabel,
                          hint: l10n.passwordHint,
                          controller: _password,
                          focusNode: _passwordFocus,
                          isPassword: true,
                          readOnly: state.loading,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          errorText: state.passwordMissing
                              ? l10n.errorPasswordRequired
                              : null,
                          onChanged: widget.onPasswordChanged,
                          onSubmitted: (_) => widget.onSubmit(),
                        ),
                        SizedBox(height: AppSpacing.fieldGap),
                        ForgotPasswordLink(onPressed: widget.onForgotPassword),
                        SizedBox(height: AuthDimens.signInSectionGap),
                        PrimaryButton(
                          label: l10n.signInButton,
                          expand: true,
                          loading: state.loading,
                          onPressed: state.canSubmit ? widget.onSubmit : null,
                        ),
                        SizedBox(height: AuthDimens.signInSectionGap),
                        OrDivider(text: l10n.orContinueWith),
                        SizedBox(height: AuthDimens.signInSocialGap),
                        const SocialButtonsRow(),
                        const Spacer(),
                        SizedBox(height: AppSpacing.s24),
                        AuthSwitchLink(
                          prompt: l10n.newToPulse,
                          action: l10n.createAccount,
                          onPressed: widget.onCreateAccount,
                        ),
                        SizedBox(height: AuthDimens.signInFooterBottom),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
