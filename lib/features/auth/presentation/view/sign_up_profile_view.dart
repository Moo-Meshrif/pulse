import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/services/photo_picker_service.dart';
import '../cubit/sign_up_cubit.dart';
import '../cubit/sign_up_state.dart';
import '../../../../core/enums/photo_choice.dart';
import '../widgets/auth_header.dart';

/// Sign-up step 4, Profile (docs/specs/auth/screens/s6-signup-profile.md); everything is optional. The
/// text controllers are local UI state, filled from the Cubit. Each field, the photo and the button
/// listen to the Cubit on their own.
class SignUpProfileView extends StatefulWidget {
  const SignUpProfileView({super.key});

  static const bioMax = 150;
  static const cityMax = 60;

  @override
  State<SignUpProfileView> createState() => _SignUpProfileViewState();
}

class _SignUpProfileViewState extends State<SignUpProfileView> {
  late final _bio = TextEditingController(text: _cubit.state.bio);
  late final _city = TextEditingController(text: _cubit.state.city);
  final _phoneFocus = FocusNode();

  SignUpCubit get _cubit => context.read<SignUpCubit>();

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(() {
      if (!_phoneFocus.hasFocus) _cubit.phoneLeft();
    });
  }

  @override
  void dispose() {
    _bio.dispose();
    _city.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final choice = await PhotoSourceSheet.show(
      context,
      hasPhoto: _cubit.state.photo != null || _cubit.state.avatarUrl != null,
    );
    if (choice == null) return;
    switch (choice) {
      case PhotoChoice.remove:
        _cubit.removePhoto();
      default:
        _cubit.pickPhoto(choice.source!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PinnedBottomCta(
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
              title: l10n.profileTitle,
              subtitle: l10n.profileSubtitle,
            ),
            SizedBox(height: AuthDimens.signUpTopGap),
            BlocSelector<
              SignUpCubit,
              SignUpState,
              ({PickedPhoto? photo, String? url})
            >(
              selector: (state) => (photo: state.photo, url: state.avatarUrl),
              builder: (context, avatar) => PhotoPickerAvatar(
                photo: avatar.photo,
                avatarUrl: avatar.url,
                onTap: _choosePhoto,
              ),
            ),
            SizedBox(height: AuthDimens.signUpTopGap),
            BlocSelector<SignUpCubit, SignUpState, bool>(
              selector: (state) => state.loading,
              builder: (context, loading) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: l10n.bioLabel,
                    hint: l10n.bioHint,
                    controller: _bio,
                    readOnly: loading,
                    minLines: 3,
                    maxLines: 3,
                    counterMax: SignUpProfileView.bioMax,
                    keyboardType: TextInputType.multiline,
                    onChanged: _cubit.bioChanged,
                  ),
                  SizedBox(height: AppSpacing.fieldGap),
                  AppTextField(
                    label: l10n.cityLabel,
                    hint: l10n.cityHint,
                    controller: _city,
                    readOnly: loading,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                        SignUpProfileView.cityMax,
                      ),
                    ],
                    onChanged: _cubit.cityChanged,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.fieldGap),
            BlocSelector<
              SignUpCubit,
              SignUpState,
              ({bool loading, bool invalid})
            >(
              selector: (state) =>
                  (loading: state.loading, invalid: state.phoneInvalidShown),
              builder: (context, phone) => PhoneField(
                initialPhone: _cubit.state.phone,
                focusNode: _phoneFocus,
                readOnly: phone.loading,
                textInputAction: TextInputAction.done,
                helperText: l10n.phoneHelper,
                errorText: phone.invalid ? l10n.errorPhone : null,
                onChanged: _cubit.phoneChanged,
                onSubmitted: (_) => _cubit.submitProfile(),
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
                (loading: state.loading, canSubmit: state.canSubmitProfile),
            builder: (context, button) => PrimaryButton(
              label: l10n.continueButton,
              expand: true,
              loading: button.loading,
              onPressed: button.canSubmit ? _cubit.submitProfile : null,
            ),
          ),
    );
  }
}
