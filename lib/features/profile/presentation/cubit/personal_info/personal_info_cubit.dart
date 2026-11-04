import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/enums/photo_source.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/services/photo_picker_service.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/utils/location_choice.dart';
import '../../../data/repository/profile_repository.dart';
import '../../../domain/entity/profile_entity.dart';
import '../../../domain/entity/profile_update_entity.dart';
import '../../../domain/event/profile_updated.dart';
import '../../utils/enums/username_status.dart';
import 'personal_info_state.dart';

/// Personal info (docs/specs/profile/screens/s3-personal-info.md): the edit form of the signed-in user's
/// own profile. Pictures are uploaded only when Save is pressed.
@injectable
class PersonalInfoCubit extends BaseCubit<PersonalInfoState>
    with EventCubitMixin<PersonalInfoState> {
  PersonalInfoCubit(this._profiles, this._photos, this._events)
    : super(const PersonalInfoState());

  static const _usernameDebounce = Duration(milliseconds: 500);

  final ProfileRepository _profiles;
  final PhotoPickerService _photos;
  final EventBus _events;

  @override
  EventBus get events => _events;

  Timer? _usernameTimer;

  Future<void> load() => run(
    _profiles.getProfile,
    loading: const PersonalInfoState(),
    onSuccess: _fromProfile,
    onFailure: (failure) =>
        state.copyWith(isLoading: false, loadFailure: failure),
  );

  PersonalInfoState _fromProfile(ProfileEntity profile) => PersonalInfoState(
    isLoading: false,
    original: profile,
    email: _profiles.email ?? '',
    fullName: profile.fullName ?? '',
    username: profile.username ?? '',
    bio: profile.bio ?? '',
    city: profile.city ?? '',
    phone: profile.phone ?? '',
    birthday: profile.birthday,
  );

  void fullNameChanged(String value) =>
      emit(state.copyWith(fullName: value, failure: null));

  void bioChanged(String value) =>
      emit(state.copyWith(bio: value, failure: null));

  void phoneChanged(String value) =>
      emit(state.copyWith(phone: value, failure: null));

  void birthdayPicked(DateTime date) =>
      emit(state.copyWith(birthday: date, failure: null));

  /// The place picker's answer: a name, or none ("Remove").
  void locationChosen(LocationChoice choice) =>
      emit(state.copyWith(city: choice.name ?? '', failure: null));

  void usernameChanged(String value) {
    _usernameTimer?.cancel();
    emit(state.copyWith(username: value, usernameStatus: UsernameStatus.idle));
    if (!state.usernameChanged || state.isUsernameFormatInvalid) return;
    if (value.trim().isEmpty) return;
    emit(state.copyWith(usernameStatus: UsernameStatus.checking));
    _usernameTimer = Timer(_usernameDebounce, () => _checkUsername(value));
  }

  Future<void> _checkUsername(String typed) async {
    final username = typed.trim().toLowerCase();
    try {
      final free = await _profiles.isUsernameAvailable(username);
      // An older answer never overwrites a newer one.
      if (state.username.trim().toLowerCase() != username) return;
      emit(
        state.copyWith(
          usernameStatus: free ? UsernameStatus.free : UsernameStatus.taken,
        ),
      );
    } on Failure {
      if (state.username.trim().toLowerCase() != username) return;
      // The save checks it again: a failed check only stops showing the spinner.
      emit(state.copyWith(usernameStatus: UsernameStatus.idle));
    }
  }

  Future<void> pickAvatar(PhotoSource source) async {
    final photo = await _photos.pick(source, crop: PhotoCrop.avatar);
    if (photo != null) {
      emit(state.copyWith(avatar: photo, removeAvatar: false));
    }
  }

  void removeAvatar() => emit(state.copyWith(avatar: null, removeAvatar: true));

  Future<void> pickCover(PhotoSource source) async {
    final photo = await _photos.pick(source, crop: PhotoCrop.cover);
    if (photo != null) emit(state.copyWith(cover: photo, removeCover: false));
  }

  void removeCover() => emit(state.copyWith(cover: null, removeCover: true));

  /// Uploads the new pictures, then writes the changed fields.
  Future<void> save() {
    final edits = state;
    return run(
      () async {
        final saved = edits.original!;
        String? avatarUrl;
        String? coverUrl;
        if (edits.avatar != null) {
          avatarUrl = await _profiles.uploadAvatar(
            edits.avatar!.bytes,
            contentType: edits.avatar!.contentType,
          );
        } else if (edits.removeAvatar && saved.avatarUrl != null) {
          await _profiles.removeAvatar();
        }
        if (edits.cover != null) {
          coverUrl = await _profiles.uploadCover(
            edits.cover!.bytes,
            contentType: edits.cover!.contentType,
          );
        } else if (edits.removeCover && saved.coverUrl != null) {
          await _profiles.removeCover();
        }
        final update = ProfileUpdateEntity(
          fullName: _changed(edits.fullName, saved.fullName),
          username: edits.usernameChanged
              ? edits.username.trim().toLowerCase()
              : null,
          bio: _changed(edits.bio, saved.bio),
          city: _changed(edits.city, saved.city),
          phone: _changedPhone(edits.phone, saved.phone),
          birthday: edits.birthday != saved.birthday ? edits.birthday : null,
          avatarUrl: avatarUrl,
          coverUrl: coverUrl,
        );
        if (update != const ProfileUpdateEntity()) {
          await _profiles.updateProfile(update);
        }
      },
      prevent: !edits.canSave,
      loading: edits.copyWith(isSaving: true, failure: null),
      onSuccess: (_) {
        fire(const ProfileUpdated());
        return state.copyWith(isSaving: false, saved: true);
      },
      onFailure: (failure) => state.copyWith(
        isSaving: false,
        usernameStatus: failure is ConflictFailure
            ? UsernameStatus.taken
            : state.usernameStatus,
        failure: failure is ConflictFailure ? null : failure,
      ),
    );
  }

  /// The trimmed [typed] text when it differs from the [saved] one, else null (left unchanged).
  String? _changed(String typed, String? saved) {
    final text = typed.trim();
    return text == (saved ?? '') ? null : text;
  }

  String? _changedPhone(String typed, String? saved) {
    final phone = typed.replaceAll(RegExp(r'\s'), '');
    return phone == (saved ?? '').replaceAll(RegExp(r'\s'), '') ? null : phone;
  }

  @override
  Future<void> close() {
    _usernameTimer?.cancel();
    return super.close();
  }
}
