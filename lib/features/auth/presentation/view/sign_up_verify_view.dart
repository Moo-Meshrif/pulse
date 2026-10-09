import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_countdown.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/sign_up_cubit.dart';
import '../cubit/sign_up_state.dart';
import '../utils/email_mask.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_link.dart';
import '../widgets/icon_tile.dart';
import '../widgets/otp_field.dart';

/// Sign-up step 2, Verify email (docs/specs/auth/screens/s4-signup-verify-email.md). The code controller is
/// local UI state, kept in step with the Cubit's `code`.
class SignUpVerifyView extends StatefulWidget {
  const SignUpVerifyView({super.key});

  @override
  State<SignUpVerifyView> createState() => _SignUpVerifyViewState();
}

class _SignUpVerifyViewState extends State<SignUpVerifyView> {
  late final _code = TextEditingController(text: _cubit.state.code);

  SignUpCubit get _cubit => context.read<SignUpCubit>();

  // The Cubit clears the code after a wrong one; the controller follows it.
  bool _codeDiffersFromField(SignUpState before, SignUpState state) =>
      state.code != _code.text;

  void _copyCodeToField(BuildContext context, SignUpState state) =>
      _code.text = state.code;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final masked = maskEmail(_cubit.state.email);
    return BlocListener<SignUpCubit, SignUpState>(
      listenWhen: _codeDiffersFromField,
      listener: _copyCodeToField,
      child: PinnedBottomCta(
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                leading: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconTile(icon: AppAssets.mail),
                ),
                title: l10n.verifyTitle,
                subtitle: l10n.verifySubtitle(masked),
                emphasis: masked,
              ),
              SizedBox(height: AuthDimens.otpTopGap),
              BlocSelector<SignUpCubit, SignUpState, bool>(
                selector: (state) => state.loading,
                builder: (context, loading) => OtpField(
                  controller: _code,
                  enabled: !loading,
                  onChanged: _cubit.codeChanged,
                ),
              ),
              SizedBox(height: AuthDimens.resendTopGap),
              const _ResendRow(),
            ],
          ),
        ),
        cta:
            BlocSelector<
              SignUpCubit,
              SignUpState,
              ({bool loading, bool canVerify})
            >(
              selector: (state) =>
                  (loading: state.loading, canVerify: state.canVerify),
              builder: (context, button) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: l10n.verify,
                    expand: true,
                    loading: button.loading,
                    onPressed: button.canVerify ? _cubit.verify : null,
                  ),
                  SizedBox(height: AuthDimens.ctaLinkGap),
                  AuthTextLink(
                    label: l10n.useDifferentEmail,
                    onPressed: button.loading ? null : _cubit.backToAccount,
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

/// "Didn't get it? **Resend code**", or "Resend code in 0:30" (grey) during the cooldown.
class _ResendRow extends StatelessWidget {
  const _ResendRow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppText(
          '${l10n.didntGetIt} ',
          style: context.text.subtitle,
          color: colors.textSecondary,
        ),
        BlocSelector<
          SignUpCubit,
          SignUpState,
          ({Duration? cooldown, bool canResend})
        >(
          selector: (state) =>
              (cooldown: state.resendIn, canResend: state.canResend),
          builder: (context, resend) => AuthTextLink(
            label: resend.cooldown == null
                ? l10n.resendCode
                : l10n.resendCodeIn(formatCountdown(resend.cooldown!)),
            onPressed: resend.canResend
                ? context.read<SignUpCubit>().resend
                : null,
          ),
        ),
      ],
    );
  }
}
