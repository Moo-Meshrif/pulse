import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../../data/enums/signup_step.dart';
import '../../data/repository/profile_repository.dart';
import '../entity/profile_update_entity.dart';

/// Sign-up step "Profile": uploads the photo if one was picked, saves the bio, city and phone that were
/// filled in, deletes the saved photo when [removeAvatar] is set and no new one was picked, and moves the resume point to Interests. With nothing given (Skip) it only moves the
/// resume point.
@injectable
class SaveProfileDetailsUseCase {
  SaveProfileDetailsUseCase(this._profiles);

  final ProfileRepository _profiles;

  Future<void> call({
    Uint8List? photo,
    String? photoContentType,
    String? bio,
    String? city,
    String? phone,
    bool removeAvatar = false,
  }) async {
    String? avatarUrl;
    if (photo == null && removeAvatar) {
      await _profiles.removeAvatar();
    }
    if (photo != null) {
      avatarUrl = await _profiles.uploadAvatar(
        photo,
        contentType: photoContentType ?? 'image/jpeg',
      );
    }
    await _profiles.updateProfile(
      ProfileUpdateEntity(
        avatarUrl: avatarUrl,
        bio: _filled(bio),
        city: _filled(city),
        phone: _filled(phone)?.replaceAll(RegExp(r'\s'), ''),
        signupStep: SignupStep.interests,
      ),
    );
  }

  String? _filled(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
