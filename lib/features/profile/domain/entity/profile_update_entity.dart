import '../../../../core/utils/equatable.dart';
import '../../data/enums/gender.dart';
import '../../data/enums/signup_step.dart';

/// The profile fields one sign-up step writes. A null field is left unchanged, so each step sends only
/// what it owns.
class ProfileUpdateEntity extends Equatable {
  final String? username;
  final String? fullName;
  final DateTime? birthday;
  final Gender? gender;
  final String? bio;
  final String? city;
  final String? phone;
  final String? avatarUrl;
  final String? coverUrl;
  final SignupStep? signupStep;

  /// Empties bio, city, phone and the photo on the profile.
  final bool clearDetails;

  const ProfileUpdateEntity({
    this.username,
    this.fullName,
    this.birthday,
    this.gender,
    this.bio,
    this.city,
    this.phone,
    this.avatarUrl,
    this.coverUrl,
    this.signupStep,
    this.clearDetails = false,
  });

  @override
  List<Object?> get props => [
    username,
    fullName,
    birthday,
    gender,
    bio,
    city,
    phone,
    avatarUrl,
    coverUrl,
    signupStep,
    clearDetails,
  ];
}
