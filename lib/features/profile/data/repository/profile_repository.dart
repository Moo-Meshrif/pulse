import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entity/last_account_entity.dart';
import '../../domain/entity/profile_entity.dart';
import '../../domain/entity/profile_update_entity.dart';
import '../datasource/profile_datasource.dart';
import '../datasource/profile_local_datasource.dart';
import '../enums/signup_step.dart';
import '../model/profile_model.dart';
import '../model/profile_update_model.dart';

/// The signed-in user's profile: from the server with a saved copy. Reads fall back to the copy when
/// offline; every successful write updates it.
abstract interface class ProfileRepository {
  /// The profile from the server (and saved locally). Only when the connection fails does it return the
  /// saved copy, if there is one; any other failure (a revoked session) is returned as it is.
  ///
  /// With [savedOnlyWhenSignupDone] the copy is used only if it says sign-up is finished: an unfinished
  /// sign-up needs the network for every step left, so there the connection failure is returned.
  Future<ProfileEntity> getProfile({bool savedOnlyWhenSignupDone = false});

  Future<bool> isUsernameAvailable(String username);

  /// Writes only the fields that are set, then saves the profile as the server now stores it, and
  /// returns it. A taken username is `ConflictFailure`.
  Future<ProfileEntity> updateProfile(ProfileUpdateEntity update);

  /// Stores the picture and returns its public URL (not yet saved on the profile).
  Future<String> uploadAvatar(Uint8List bytes, {required String contentType});

  /// Deletes the picture on the server and in the saved copy.
  Future<void> removeAvatar();

  /// Forgets the saved copy of the signed-in user's profile (call before signing out).
  Future<void> clearLocalProfile();

  /// The account saved last, usable with no session (null when none is saved or it has no username).
  LastAccountEntity? lastAccount();

  /// Forgets the account [lastAccount] returns (the saved copy and the pointer), with no session needed.
  Future<void> forgetLastAccount();
}

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote, this._local);

  final ProfileDatasource _remote;
  final ProfileLocalDatasource _local;

  @override
  Future<ProfileEntity> getProfile({
    bool savedOnlyWhenSignupDone = false,
  }) async {
    try {
      final profile = await _remote.getProfile();
      await _local.write(profile);
      return _toEntity(profile);
    } on Failure catch (failure) {
      // Only a lost connection falls back to the copy: anything else is a real answer.
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final userId = _remote.currentUserId;
        final saved = userId == null ? null : _local.read(userId);
        final usable =
            saved != null &&
            (!savedOnlyWhenSignupDone ||
                saved.signupStep == SignupStep.complete);
        if (usable) return _toEntity(saved);
      }
      rethrow;
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) =>
      _remote.isUsernameAvailable(username);

  @override
  Future<ProfileEntity> updateProfile(ProfileUpdateEntity update) async {
    final profile = await _remote.updateProfile(_toUpdateModel(update));
    await _local.write(profile);
    return _toEntity(profile);
  }

  @override
  Future<String> uploadAvatar(Uint8List bytes, {required String contentType}) =>
      _remote.uploadAvatar(bytes, contentType: contentType);

  @override
  Future<void> removeAvatar() async {
    await _remote.removeAvatar();
    final userId = _remote.currentUserId;
    final saved = userId == null ? null : _local.read(userId);
    if (saved != null) await _local.write(saved.copyWith(clearAvatar: true));
  }

  @override
  Future<void> clearLocalProfile() async {
    final userId = _remote.currentUserId;
    if (userId != null) await _local.clear(userId);
  }

  @override
  LastAccountEntity? lastAccount() {
    final saved = _local.readLast();
    final id = saved?.id;
    final username = saved?.username;
    if (saved == null || id == null || username == null || username.isEmpty) {
      return null;
    }
    return LastAccountEntity(
      id: id,
      username: username,
      fullName: saved.fullName,
      avatarUrl: saved.avatarUrl,
    );
  }

  @override
  Future<void> forgetLastAccount() async {
    final id = _local.readLast()?.id;
    if (id != null) await _local.clear(id);
  }

  /// The app's concept of the profile; the wire model never builds it.
  ProfileEntity _toEntity(ProfileModel model) => ProfileEntity(
    id: model.id,
    username: model.username,
    fullName: model.fullName,
    birthday: model.birthday,
    gender: model.gender,
    bio: model.bio,
    city: model.city,
    phone: model.phone,
    avatarUrl: model.avatarUrl,
    signupStep: model.signupStep,
  );

  ProfileUpdateModel _toUpdateModel(ProfileUpdateEntity update) =>
      ProfileUpdateModel(
        username: update.username,
        fullName: update.fullName,
        birthday: update.birthday,
        gender: update.gender,
        bio: update.bio,
        city: update.city,
        phone: update.phone,
        avatarUrl: update.avatarUrl,
        signupStep: update.signupStep,
        clearDetails: update.clearDetails,
      );
}
