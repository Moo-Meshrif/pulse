import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/utils/either.dart';
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

  Future<Result<Unit>> call({
    Uint8List? photo,
    String? photoContentType,
    String? bio,
    String? city,
    String? phone,
    bool removeAvatar = false,
  }) async {
    String? avatarUrl;
    if (photo == null && removeAvatar) {
      final removed = await _profiles.removeAvatar();
      if (removed case Left(:final value)) return Left(value);
    }
    if (photo != null) {
      final uploaded = await _profiles.uploadAvatar(
        photo,
        contentType: photoContentType ?? 'image/jpeg',
      );
      switch (uploaded) {
        case Left(:final value):
          return Left(value);
        case Right(:final value):
          avatarUrl = value;
      }
    }
    final saved = await _profiles.updateProfile(
      ProfileUpdateEntity(
        avatarUrl: avatarUrl,
        bio: _filled(bio),
        city: _filled(city),
        phone: _filled(phone)?.replaceAll(RegExp(r'\s'), ''),
        signupStep: SignupStep.interests,
      ),
    );
    return saved.map((_) => unit);
  }

  String? _filled(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
