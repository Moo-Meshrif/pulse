import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/enums/photo_choice.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/photo_picker_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/utils/birthday.dart';
import '../../../../core/utils/location_choice.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/personal_info/personal_info_cubit.dart';
import '../cubit/personal_info/personal_info_state.dart';
import '../dimens/profile_dimens.dart';
import '../utils/enums/username_status.dart';
import 'personal_info_avatar.dart';

/// The fields. Its text controllers are local UI state, filled once from the loaded profile.
class PersonalInfoForm extends StatefulWidget {
  const PersonalInfoForm({super.key});

  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  static const _bioMax = PersonalInfoState.bioMax;

  late final PersonalInfoCubit _cubit = context.read<PersonalInfoCubit>();
  late final _fullName = TextEditingController(text: _cubit.state.fullName);
  late final _username = TextEditingController(text: _cubit.state.username);
  late final _bio = TextEditingController(text: _cubit.state.bio);
  late final _location = TextEditingController(text: _cubit.state.city);
  late final _email = TextEditingController(text: _cubit.state.email);
  late final _birthday = TextEditingController(
    text: _birthdayText(_cubit.state.birthday),
  );

  static String _birthdayText(DateTime? date) =>
      date == null ? '' : formatBirthday(date);

  @override
  void dispose() {
    _fullName.dispose();
    _username.dispose();
    _bio.dispose();
    _location.dispose();
    _email.dispose();
    _birthday.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto({required bool cover}) async {
    final state = _cubit.state;
    final saved = cover ? state.original?.coverUrl : state.original?.avatarUrl;
    final picked = cover ? state.cover : state.avatar;
    final removed = cover ? state.removeCover : state.removeAvatar;
    final hasPhoto =
        picked != null || (!removed && saved != null && saved.isNotEmpty);
    final choice = await PhotoSourceSheet.show(context, hasPhoto: hasPhoto);
    if (choice == null) return;
    final source = choice.source;
    if (choice == PhotoChoice.remove || source == null) {
      cover ? _cubit.removeCover() : _cubit.removeAvatar();
    } else {
      await (cover ? _cubit.pickCover(source) : _cubit.pickAvatar(source));
    }
  }

  Future<void> _pickLocation() async {
    final current = _cubit.state.city;
    final choice = await AppNavigator.push<Object?>(
      context,
      AppRoutes.pickPlace,
      arguments: current.isEmpty ? null : current,
    );
    if (choice is! LocationChoice) return;
    _location.text = choice.name ?? '';
    _cubit.locationChosen(choice);
  }

  Future<void> _pickBirthday() async {
    final today = DateUtils.dateOnly(clock.now());
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _cubit.state.birthday ?? DateTime(today.year - minAge, today.month),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (picked == null) return;
    _birthday.text = _birthdayText(picked);
    _cubit.birthdayPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final initial = _cubit.state.original;
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.formSide,
        AppSpacing.s16,
        AppSpacing.formSide,
        AppSpacing.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child:
                BlocSelector<
                  PersonalInfoCubit,
                  PersonalInfoState,
                  ({PickedPhoto? photo, String? url})
                >(
                  selector: (state) => (
                    photo: state.avatar,
                    url: state.removeAvatar ? null : state.original?.avatarUrl,
                  ),
                  builder: (context, avatar) => PersonalInfoAvatar(
                    name: initial?.fullName,
                    seed: initial?.id,
                    photo: avatar.photo,
                    url: avatar.url,
                    onTap: () => _choosePhoto(cover: false),
                  ),
                ),
          ),
          SizedBox(height: ProfileDimens.editLinkGap),
          Center(
            child: GestureDetector(
              onTap: () => _choosePhoto(cover: true),
              behavior: HitTestBehavior.opaque,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSizes.tapTarget,
                ),
                child: Center(
                  widthFactor: 1,
                  child: AppText(
                    l10n.personalInfoChangeCover,
                    style: context.text.moreLink,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.s8),
          AppTextField(
            label: l10n.fullNameLabel,
            controller: _fullName,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            onChanged: _cubit.fullNameChanged,
          ),
          SizedBox(height: AppSpacing.fieldGap),
          BlocBuilder<PersonalInfoCubit, PersonalInfoState>(
            buildWhen: (before, now) =>
                before.usernameStatus != now.usernameStatus ||
                before.username != now.username,
            builder: (context, state) => AppTextField(
              label: l10n.usernameLabel,
              controller: _username,
              prefixText: '@',
              forceLtr: true,
              textInputAction: TextInputAction.next,
              errorText: state.isUsernameFormatInvalid
                  ? l10n.usernameHelper
                  : state.usernameStatus == UsernameStatus.taken
                  ? l10n.errorUsernameTaken
                  : null,
              suffix: _UsernameStatusIcon(status: state.usernameStatus),
              onChanged: _cubit.usernameChanged,
            ),
          ),
          SizedBox(height: AppSpacing.fieldGap),
          AppTextField(
            label: l10n.bioLabel,
            hint: l10n.bioHint,
            controller: _bio,
            minLines: 3,
            maxLines: 3,
            counterMax: _bioMax,
            keyboardType: TextInputType.multiline,
            onChanged: _cubit.bioChanged,
          ),
          SizedBox(height: AppSpacing.fieldGap),
          AppTextField(
            label: l10n.personalInfoLocationLabel,
            hint: l10n.personalInfoLocationHint,
            controller: _location,
            readOnly: true,
            onTap: _pickLocation,
            prefix: Padding(
              padding: EdgeInsetsDirectional.only(start: AppSpacing.s12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppSvgIcon(
                  AppAssets.location,
                  size: ProfileDimens.editLocationIcon,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.fieldGap),
          AppTextField(
            label: l10n.emailLabel,
            controller: _email,
            readOnly: true,
            forceLtr: true,
          ),
          SizedBox(height: AppSpacing.fieldGap),
          BlocSelector<PersonalInfoCubit, PersonalInfoState, bool>(
            selector: (state) => state.isPhoneInvalid,
            builder: (context, invalid) => PhoneField(
              initialPhone: _cubit.state.phone,
              errorText: invalid ? l10n.errorPhone : null,
              textInputAction: TextInputAction.next,
              onChanged: _cubit.phoneChanged,
            ),
          ),
          SizedBox(height: AppSpacing.fieldGap),
          BlocSelector<PersonalInfoCubit, PersonalInfoState, bool>(
            selector: (state) => state.isBirthdayInvalid,
            builder: (context, invalid) => AppTextField(
              label: l10n.birthdayLabel,
              hint: l10n.birthdayHint,
              controller: _birthday,
              readOnly: true,
              onTap: _pickBirthday,
              errorText: invalid ? l10n.errorMinAge : null,
            ),
          ),
          SizedBox(height: AppSpacing.s12),
          AppText(
            l10n.personalInfoPrivateNote,
            style: context.text.bodyXs,
            color: colors.textSecondary,
          ),
          SizedBox(height: AppSpacing.s24),
          BlocSelector<
            PersonalInfoCubit,
            PersonalInfoState,
            ({bool canSave, bool saving})
          >(
            selector: (state) =>
                (canSave: state.canSave, saving: state.isSaving),
            builder: (context, save) => PrimaryButton(
              label: l10n.personalInfoSave,
              expand: true,
              loading: save.saving,
              onPressed: save.canSave ? _cubit.save : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsernameStatusIcon extends StatelessWidget {
  const _UsernameStatusIcon({required this.status});

  final UsernameStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = ProfileDimens.editBadgeIcon;
    return switch (status) {
      UsernameStatus.checking => Padding(
        padding: EdgeInsetsDirectional.only(end: AppSpacing.s12),
        child: PulseLineLoader(color: colors.textSecondary, width: size),
      ),
      UsernameStatus.free => Padding(
        padding: EdgeInsetsDirectional.only(end: AppSpacing.s12),
        child: AppSvgIcon(AppAssets.check, size: size, color: colors.primary),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
