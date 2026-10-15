import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/sign_in_cubit.dart';
import '../cubit/sign_in_state.dart';
import '../dimens/auth_dimens.dart';
import '../widgets/account_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_switch_link.dart';
import '../widgets/forgot_password_link.dart';
import '../widgets/or_divider.dart';
import '../widgets/session_banner.dart';
import '../widgets/social_buttons_row.dart';

/// Sign in's UI (docs/specs/auth/screens/s1-signin.md). The text controllers are local UI state. Only
/// the parts that depend on the Cubit's state listen to it (fields: `loading`; button: `loading` and
/// `canSubmit`), so typing never rebuilds the rest of the page.
class SignInView extends StatefulWidget {
  const SignInView({super.key});

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

  SignInCubit get _cubit => context.read<SignInCubit>();

  // The button only reads these two, so a keystroke rebuilds it only when one flips.
  bool _buttonStateChanged(SignInState before, SignInState state) =>
      before.loading != state.loading || before.canSubmit != state.canSubmit;

  bool _accountPartChanged(SignInState before, SignInState state) =>
      before.reason != state.reason || before.account != state.account;

  /// Logo, title, subtitle, then (after a session ended) the banner, then the saved account or, as in a
  /// plain Sign in, the Email or username field.
  Widget _topPart(BuildContext context, SignInState state) {
    final l10n = context.l10n;
    final account = state.account;
    final reason = state.reason;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthHeader(
          leading: const Align(
            alignment: AlignmentDirectional.centerStart,
            child: LogoTile(),
          ),
          title: l10n.signInTitle,
          subtitle: account == null
              ? l10n.signInSubtitle
              : l10n.signedOutSubtitle,
        ),
        if (reason != null) ...[
          SizedBox(height: AuthDimens.signedOutBannerGap),
          SessionBanner(reason: reason),
          SizedBox(height: AuthDimens.signedOutBannerGap),
        ] else
          SizedBox(height: AuthDimens.signInFormGap),
        if (account != null)
          _LoadingSelector(
            builder: (loading) => AccountCard(
              id: account.id,
              fullName: account.fullName,
              username: account.username,
              avatarUrl: account.avatarUrl,
              onNotYou: loading ? null : _cubit.forgetAccount,
            ),
          )
        else
          _LoadingSelector(
            builder: (loading) => AppTextField(
              label: l10n.identifierLabel,
              hint: l10n.emailHint,
              controller: _identifier,
              forceLtr: true,
              readOnly: loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              onChanged: _cubit.identifierChanged,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
          ),
      ],
    );
  }

  void _openForgotPassword() =>
      AppNavigator.push(context, AppRoutes.forgotPassword);

  void _openRegister() => AppNavigator.push(context, AppRoutes.register);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      bottomSpace: AppSpacing.s24,
      showTopBar: false,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.formSide),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AuthDimens.signInTopGap),
                    // Header, banner and the account: they change together when a session ended
                    // and when "Not you?" is tapped.
                    BlocBuilder<SignInCubit, SignInState>(
                      buildWhen: _accountPartChanged,
                      builder: (context, state) => _topPart(context, state),
                    ),
                    SizedBox(height: AppSpacing.fieldGap),
                    _LoadingSelector(
                      builder: (loading) => AppTextField(
                        label: l10n.passwordLabel,
                        hint: l10n.passwordHint,
                        controller: _password,
                        focusNode: _passwordFocus,
                        // With the account named there is only the password left to type.
                        autofocus: _cubit.state.account != null,
                        isPassword: true,
                        readOnly: loading,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onChanged: context.read<SignInCubit>().passwordChanged,
                        onSubmitted: (_) => _cubit.submit(),
                      ),
                    ),
                    SizedBox(height: AppSpacing.fieldGap),
                    ForgotPasswordLink(onPressed: _openForgotPassword),
                    SizedBox(height: AuthDimens.signInSectionGap),
                    BlocBuilder<SignInCubit, SignInState>(
                      buildWhen: _buttonStateChanged,
                      builder: (context, state) => PrimaryButton(
                        label: l10n.signInButton,
                        expand: true,
                        loading: state.loading,
                        onPressed: state.canSubmit ? _cubit.submit : null,
                      ),
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
                      onPressed: _openRegister,
                    ),
                    SizedBox(height: AuthDimens.signInFooterBottom),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rebuilds its child only when the request's `loading` flag flips.
class _LoadingSelector extends StatelessWidget {
  const _LoadingSelector({required this.builder});

  final Widget Function(bool loading) builder;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SignInCubit, SignInState, bool>(
        selector: (state) => state.loading,
        builder: (context, loading) => builder(loading),
      );
}
