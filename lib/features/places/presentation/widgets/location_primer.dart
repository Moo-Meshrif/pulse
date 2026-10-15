import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/enums/permission_access.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/add_location_cubit.dart';
import '../cubit/add_location_state.dart';

/// Panel 4: why Pulse asks for the location, before the system prompt. When only Settings can turn it on
/// the button opens Settings.
class LocationPrimer extends StatelessWidget {
  const LocationPrimer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AddLocationCubit>();
    return BlocSelector<AddLocationCubit, AddLocationState, bool>(
      selector: (state) => state.access == PermissionAccess.blocked,
      builder: (context, isBlocked) => AppEmpty(
        icon: AppAssets.crosshairThin,
        title: l10n.locationPrimerTitle,
        message: l10n.locationPrimerBody,
        primaryLabel: isBlocked
            ? l10n.locationOpenSettings
            : l10n.locationAllow,
        onPrimary: cubit.allowLocation,
        secondaryLabel: l10n.locationNotNow,
        onSecondary: cubit.notNow,
      ),
    );
  }
}
