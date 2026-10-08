import '../../../../core/utils/equatable.dart';
import '../../data/enums/gender.dart';
import '../../data/enums/signup_step.dart';

/// The signed-in user's own profile, as the app uses it.
class ProfileEntity extends Equatable {
  final String? id;
  final String? username;
  final String? fullName;
  final DateTime? birthday;
  final Gender? gender;
  final String? bio;
  final String? city;
  final String? phone;
  final String? avatarUrl;
  final SignupStep? signupStep;

  const ProfileEntity({
    this.id,
    this.username,
    this.fullName,
    this.birthday,
    this.gender,
    this.bio,
    this.city,
    this.phone,
    this.avatarUrl,
    this.signupStep,
  });

  /// Sign-up is finished (a profile with no known step counts as not finished).
  bool get isSignupComplete => signupStep == SignupStep.complete;

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    birthday,
    gender,
    bio,
    city,
    phone,
    avatarUrl,
    signupStep,
  ];
}
