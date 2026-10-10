import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/sign_up_cubit.dart';
import '../cubit/sign_up_state.dart';
import '../utils/enums/legal_document.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_switch_link.dart';
import '../widgets/labeled_checkbox.dart';
import '../widgets/or_divider.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/social_buttons_row.dart';
import '../widgets/terms_agreement_label.dart';

/// Sign-up step 1, Account (docs/specs/auth/screens/s3-signup-account.md). The controllers and focus nodes
/// are local UI state, filled from the Cubit so a return from Verify email keeps what was typed. Each
/// field, the meter, the checkbox and the button listen to the Cubit on their own.
class SignUpAccountView extends StatefulWidget {
  const SignUpAccountView({super.key});

  @override
  State<SignUpAccountView> createState() => _SignUpAccountViewState();
}

class _SignUpAccountViewState extends State<SignUpAccountView> {
  late final _email = TextEditingController(text: _cubit.state.email);
  late final _password = TextEditingController(text: _cubit.state.password);
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  SignUpCubit get _cubit => context.read<SignUpCubit>();

  void _openLegalDocument(LegalDocument document) =>
      AppNavigator.push(context, document.route);

  void _openSignIn() => AppNavigator.resetTo(context, AppRoutes.signIn);

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _cubit.emailLeft();
    });
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) _cubit.passwordLeft();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final noteStyle = context.text.caption;
    return PinnedBottomCta(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.formSide,
          AuthDimens.signUpTopGap,
          AppSpacing.formSide,
          AppSpacing.s24,
        ),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: l10n.signUpTitle,
                subtitle: l10n.signUpSubtitle,
              ),
              SizedBox(height: AuthDimens.signUpTopGap),
              BlocSelector<
                SignUpCubit,
                SignUpState,
                ({bool loading, bool invalid})
              >(
                selector: (state) =>
                    (loading: state.loading, invalid: state.emailInvalidShown),
                builder: (context, email) => AppTextField(
                  label: l10n.emailLabel,
                  required: true,
                  hint: l10n.emailHint,
                  controller: _email,
                  focusNode: _emailFocus,
                  forceLtr: true,
                  readOnly: email.loading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: email.invalid ? l10n.errorInvalidEmail : null,
                  onChanged: _cubit.emailChanged,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
              ),
              SizedBox(height: AppSpacing.fieldGap),
              BlocSelector<
                SignUpCubit,
                SignUpState,
                ({bool loading, bool tooShort})
              >(
                selector: (state) => (
                  loading: state.loading,
                  tooShort: state.passwordShortShown,
                ),
                builder: (context, password) => AppTextField(
                  label: l10n.passwordLabel,
                  required: true,
                  hint: l10n.passwordHintMin,
                  controller: _password,
                  focusNode: _passwordFocus,
                  isPassword: true,
                  readOnly: password.loading,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: password.tooShort ? l10n.errorPasswordShort : null,
                  onChanged: _cubit.passwordChanged,
                  onSubmitted: (_) => _cubit.submitAccount(),
                ),
              ),
              BlocSelector<SignUpCubit, SignUpState, String>(
                selector: (state) => state.password,
                builder: (context, password) => password.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(
                          top: AuthDimens.signUpMeterGap,
                        ),
                        child: PasswordStrengthMeter(password: password),
                      ),
              ),
              SizedBox(height: AuthDimens.signUpTermsGap),
              BlocSelector<SignUpCubit, SignUpState, bool>(
                selector: (state) => state.termsAccepted,
                builder: (context, accepted) => LabeledCheckbox(
                  checked: accepted,
                  onChanged: _cubit.termsChanged,
                  label: TermsAgreementLabel(onOpen: _openLegalDocument),
                ),
              ),
              SizedBox(height: AuthDimens.signUpNoteGap),
              Text.rich(
                TextSpan(
                  style: noteStyle.copyWith(color: colors.textSecondary),
                  children: [
                    TextSpan(
                      text: '* ',
                      style: TextStyle(color: colors.danger),
                    ),
                    TextSpan(text: l10n.required),
                  ],
                ),
              ),
              SizedBox(height: AuthDimens.signUpDividerGap),
              OrDivider(text: l10n.orSignUpWith),
              SizedBox(height: AuthDimens.signUpSocialGap),
              const SocialButtonsRow(),
            ],
          ),
        ),
      ),
      cta: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocSelector<
            SignUpCubit,
            SignUpState,
            ({bool loading, bool canSubmit})
          >(
            selector: (state) =>
                (loading: state.loading, canSubmit: state.canSubmitAccount),
            builder: (context, button) => PrimaryButton(
              label: l10n.continueButton,
              expand: true,
              loading: button.loading,
              onPressed: button.canSubmit ? _cubit.submitAccount : null,
            ),
          ),
          SizedBox(height: AuthDimens.ctaLinkGap),
          AuthSwitchLink(
            prompt: l10n.alreadyOnPulse,
            action: l10n.signIn,
            onPressed: _openSignIn,
          ),
        ],
      ),
    );
  }
}
