import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../profile/data/enums/gender.dart';
import '../cubit/sign_up_cubit.dart';
import '../cubit/sign_up_state.dart';
import '../utils/birthday.dart';
import '../utils/l10n/gender_l10n.dart';
import '../widgets/auth_header.dart';

/// Sign-up step 3, About you (docs/specs/auth/screens/s5-signup-about-you.md). The text controllers are
/// local UI state, filled from the Cubit so coming back keeps what was typed. Each field and the button
/// listen to the Cubit on their own.
class SignUpAboutView extends StatefulWidget {
  const SignUpAboutView({super.key});

  @override
  State<SignUpAboutView> createState() => _SignUpAboutViewState();
}

class _SignUpAboutViewState extends State<SignUpAboutView> {
  late final _fullName = TextEditingController(text: _cubit.state.fullName);
  late final _username = TextEditingController(text: _cubit.state.username);
  final _usernameFocus = FocusNode();
  late final _birthday = TextEditingController(
    text: _birthdayText(_cubit.state.birthday),
  );

  SignUpCubit get _cubit => context.read<SignUpCubit>();

  static String _birthdayText(DateTime? date) =>
      date == null ? '' : formatBirthday(date);

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(() {
      if (!_usernameFocus.hasFocus) _cubit.usernameLeft();
    });
  }

  @override
  void dispose() {
    _fullName.dispose();
    _username.dispose();
    _usernameFocus.dispose();
    _birthday.dispose();
    super.dispose();
  }

  bool _birthdayChanged(SignUpState before, SignUpState state) =>
      before.birthday != state.birthday;

  void _showBirthdayInField(BuildContext context, SignUpState state) =>
      _birthday.text = _birthdayText(state.birthday);

  Future<void> _pickBirthday() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _cubit.state.birthday ?? DateTime(today.year - minAge),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (picked != null) _cubit.birthdayPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    return BlocListener<SignUpCubit, SignUpState>(
      listenWhen: _birthdayChanged,
      listener: _showBirthdayInField,
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
              AuthHeader(title: l10n.aboutTitle, subtitle: l10n.aboutSubtitle),
              SizedBox(height: AuthDimens.signUpTopGap),
              BlocSelector<SignUpCubit, SignUpState, bool>(
                selector: (state) => state.loading,
                builder: (context, loading) => AppTextField(
                  label: l10n.fullNameLabel,
                  required: true,
                  hint: l10n.fullNameHint,
                  controller: _fullName,
                  readOnly: loading,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  onChanged: _cubit.fullNameChanged,
                ),
              ),
              SizedBox(height: AppSpacing.fieldGap),
              BlocSelector<
                SignUpCubit,
                SignUpState,
                ({bool loading, bool invalid})
              >(
                selector: (state) => (
                  loading: state.loading,
                  invalid: state.usernameInvalidShown,
                ),
                builder: (context, username) => AppTextField(
                  label: l10n.usernameLabel,
                  required: true,
                  hint: l10n.usernameHint,
                  prefixText: '@',
                  controller: _username,
                  focusNode: _usernameFocus,
                  forceLtr: true,
                  readOnly: username.loading,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newUsername],
                  helperText: l10n.usernameHelper,
                  errorText: username.invalid ? l10n.usernameHelper : null,
                  onChanged: _cubit.usernameChanged,
                ),
              ),
              SizedBox(height: AppSpacing.fieldGap),
              BlocSelector<
                SignUpCubit,
                SignUpState,
                ({bool loading, bool underage})
              >(
                selector: (state) =>
                    (loading: state.loading, underage: state.underage),
                builder: (context, birthday) => AppTextField(
                  label: l10n.birthdayLabel,
                  required: true,
                  hint: l10n.birthdayHint,
                  controller: _birthday,
                  forceLtr: true,
                  readOnly: true,
                  enabled: !birthday.loading,
                  onTap: _pickBirthday,
                  helperText: l10n.birthdayHelper,
                  errorText: birthday.underage ? l10n.errorMinAge : null,
                ),
              ),
              SizedBox(height: AppSpacing.fieldGap),
              Text.rich(
                TextSpan(
                  style: context.text.label.copyWith(color: colors.textPrimary),
                  children: [
                    TextSpan(text: l10n.genderLabel),
                    TextSpan(
                      text: ' ${l10n.genderOptional}',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.s8),
              BlocSelector<SignUpCubit, SignUpState, Gender?>(
                selector: (state) => state.gender,
                builder: (context, selected) => Wrap(
                  spacing: AuthDimens.chipWrapSpacing,
                  runSpacing: AuthDimens.chipWrapSpacing,
                  children: [
                    for (final gender in Gender.values)
                      SelectableChip(
                        label: gender.l10n(context),
                        selected: selected == gender,
                        height: AuthDimens.genderChipHeight,
                        onTap: () => _cubit.genderToggled(gender),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        cta:
            BlocSelector<
              SignUpCubit,
              SignUpState,
              ({bool loading, bool canSubmit})
            >(
              selector: (state) =>
                  (loading: state.loading, canSubmit: state.canSubmitAbout),
              builder: (context, button) => PrimaryButton(
                label: l10n.continueButton,
                expand: true,
                loading: button.loading,
                onPressed: button.canSubmit ? _cubit.submitAbout : null,
              ),
            ),
      ),
    );
  }
}
