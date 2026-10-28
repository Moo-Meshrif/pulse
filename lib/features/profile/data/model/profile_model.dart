import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/gender.dart';
import '../enums/signup_step.dart';

/// A row of `public.profiles`: the wire shape. It knows nothing about entities: the repository maps it.
class ProfileModel extends Equatable {
  final String? id;
  final String? username;
  final String? fullName;
  final DateTime? birthday;
  final Gender? gender;
  final String? bio;
  final String? city;
  final String? phone;
  final String? avatarUrl;
  final String? coverUrl;
  final bool isVerified;
  final SignupStep? signupStep;

  const ProfileModel({
    this.id,
    this.username,
    this.fullName,
    this.birthday,
    this.gender,
    this.bio,
    this.city,
    this.phone,
    this.avatarUrl,
    this.coverUrl,
    this.isVerified = false,
    this.signupStep,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: JsonMapper.string(json['id']),
    username: JsonMapper.string(json['username']),
    fullName: JsonMapper.string(json['full_name']),
    birthday: JsonMapper.date(json['birthday']),
    gender: Gender.fromJson(json['gender']),
    bio: JsonMapper.string(json['bio']),
    city: JsonMapper.string(json['city']),
    phone: JsonMapper.string(json['phone']),
    avatarUrl: JsonMapper.string(json['avatar_url']),
    coverUrl: JsonMapper.string(json['cover_url']),
    isVerified: JsonMapper.boolean(json['is_verified']) ?? false,
    signupStep: SignupStep.fromJson(json['signup_step']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'full_name': fullName,
    'birthday': birthday?.toIso8601String(),
    'gender': gender?.value,
    'bio': bio,
    'city': city,
    'phone': phone,
    'avatar_url': avatarUrl,
    'cover_url': coverUrl,
    'is_verified': isVerified,
    'signup_step': signupStep?.number,
  };

  ProfileModel copyWith({
    String? username,
    String? fullName,
    DateTime? birthday,
    Gender? gender,
    String? bio,
    String? city,
    String? phone,
    String? avatarUrl,
    bool clearAvatar = false,
    String? coverUrl,
    bool clearCover = false,
    SignupStep? signupStep,
  }) => ProfileModel(
    id: id,
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    birthday: birthday ?? this.birthday,
    gender: gender ?? this.gender,
    bio: bio ?? this.bio,
    city: city ?? this.city,
    phone: phone ?? this.phone,
    avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
    coverUrl: clearCover ? null : (coverUrl ?? this.coverUrl),
    isVerified: isVerified,
    signupStep: signupStep ?? this.signupStep,
  );

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
    coverUrl,
    isVerified,
    signupStep,
  ];
}
