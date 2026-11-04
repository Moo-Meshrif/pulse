import '../../../../core/utils/equatable.dart';
import '../enums/gender.dart';
import '../enums/signup_step.dart';

/// The columns a sign-up step writes to `public.profiles`. A null field is left out of the request, so
/// each step sends only what it owns (the database allows no other column).
class ProfileUpdateModel extends Equatable {
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

  /// Sets bio, city, phone and avatar_url to null (Skip with discard); fields given beside it win.
  final bool clearDetails;

  const ProfileUpdateModel({
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

  /// Only the fields that are set. The birthday is a date (`YYYY-MM-DD`), not a timestamp.
  Map<String, dynamic> toJson() => {
    if (clearDetails) ...{
      'bio': null,
      'city': null,
      'phone': null,
      'avatar_url': null,
    },
    if (username != null) 'username': username,
    if (fullName != null) 'full_name': fullName,
    if (birthday != null) 'birthday': _dateOnly(birthday!),
    if (gender != null) 'gender': gender!.value,
    // An empty text clears the column (the phone check allows no empty string).
    if (bio != null) 'bio': bio!.isEmpty ? null : bio,
    if (city != null) 'city': city!.isEmpty ? null : city,
    if (phone != null) 'phone': phone!.isEmpty ? null : phone,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (coverUrl != null) 'cover_url': coverUrl,
    if (signupStep != null) 'signup_step': signupStep!.number,
  };

  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

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
