import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entity/profile_entity.dart';
import '../../domain/entity/profile_update_entity.dart';
import '../datasource/profile_datasource.dart';
import '../datasource/profile_local_datasource.dart';
import '../model/profile_model.dart';
import '../model/profile_update_model.dart';

/// The signed-in user's profile: from the server with a saved copy. Reads fall back to the copy when
/// offline; every successful write updates it.
abstract interface class ProfileRepository {
  /// The profile from the server (and saved locally). Only when the connection fails does it return the
  /// saved copy, if there is one; any other failure (a revoked session) is returned as it is.
  Future<ProfileEntity> getProfile();

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
}

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote, this._local);

  final ProfileDatasource _remote;
  final ProfileLocalDatasource _local;

  @override
  Future<ProfileEntity> getProfile() async {
    try {
      final profile = await _remote.getProfile();
      await _local.write(profile);
      return _toEntity(profile);
    } on Failure catch (failure) {
      // Only a lost connection falls back to the copy: anything else is a real answer.
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final userId = _remote.currentUserId;
        final saved = userId == null ? null : _local.read(userId);
        if (saved != null) return _toEntity(saved);
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
      );
}
