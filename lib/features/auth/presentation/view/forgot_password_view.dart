import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/forgot_password_state.dart';
import '../widgets/auth_back_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/icon_tile.dart';

/// Forgot password's pure UI (docs/specs/auth/screens/s2-forgot-password.md). The email controller and
/// focus node are local UI state; "Back to sign in" is pinned above the keyboard.
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({
    super.key,
    required this.state,
    required this.onEmailChanged,
    required this.onSubmit,
    required this.onBack,
  });

  final ForgotPasswordState state;
  final ValueChanged<String> onEmailChanged;
  final VoidCallback onSubmit;

  /// The back arrow and "Back to sign in".
  final VoidCallback onBack;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _email = TextEditingController();
  final _emailFocus = FocusNode();

  @override
  void didUpdateWidget(ForgotPasswordView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.focusRequest != oldWidget.state.focusRequest) {
      _emailFocus.requestFocus();
      _email.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _email.text.length,
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = widget.state;
    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: PinnedBottomCta(
            body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      child: AuthBackButton(onPressed: widget.onBack),
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
                          AppTextField(
                            label: l10n.emailLabel,
                            hint: l10n.emailHint,
                            controller: _email,
                            focusNode: _emailFocus,
                            forceLtr: true,
                            readOnly: state.loading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.email],
                            errorText: state.invalidEmail
                                ? l10n.errorInvalidEmail
                                : null,
                            onChanged: widget.onEmailChanged,
                            onSubmitted: (_) {
                              if (state.canSubmit) widget.onSubmit();
                            },
                          ),
                          SizedBox(height: AuthDimens.formToButtonGap),
                          PrimaryButton(
                            label: l10n.sendResetLink,
                            expand: true,
                            loading: state.loading,
                            onPressed: state.canSubmit ? widget.onSubmit : null,
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
              onPressed: widget.onBack,
            ),
          ),
        ),
      ),
    );
  }
}
