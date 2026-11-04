import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../domain/use_case/get_current_user_id_use_case.dart';
import 'other_profile_screen.dart';
import 'profile_screen.dart';

class ProfileRouteScreen extends StatelessWidget {
  const ProfileRouteScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) =>
      userId == getIt<GetCurrentUserIdUseCase>()()
      ? const ProfileScreen(showBack: true)
      : OtherProfileScreen(userId: userId);
}
