import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entity/place_entity.dart';
import '../cubit/add_location_cubit.dart';
import '../cubit/add_location_state.dart';
import '../dimens/location_dimens.dart';
import '../utils/place_detail.dart';
import 'location_notice_row.dart';
import 'location_place_row.dart';
import 'location_section.dart';

/// Panel 1: where you are, the places near you, and the last places you picked.
class AddLocationHome extends StatelessWidget {
  const AddLocationHome({super.key});

  Future<void> _useCurrent(BuildContext context, AddLocationCubit cubit) async {
    final message = context.l10n.locationCurrentUnavailable;
    if (!await cubit.useCurrentLocation()) Notices.error(message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AddLocationCubit>();
    return BlocBuilder<AddLocationCubit, AddLocationState>(
      builder: (context, state) {
        bool isSelected(PlaceEntity place) =>
            state.current != null && state.current == place.displayName;
        final here = state.currentPlace;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.cardMargin,
            AppSpacing.s8,
            AppSpacing.cardMargin,
            AppSpacing.s24,
          ),
          children: [
            if (state.isOffline && !state.hasLocationAccess)
              LocationNoticeRow(message: l10n.locationOffline),
            if (state.isLoadingNearby)
              Padding(
                padding: EdgeInsets.all(AppSpacing.s16),
                child: Center(
                  child: PulseLineLoader(
                    color: context.appColors.primary,
                    width: LocationDimens.loaderWidth,
                  ),
                ),
              ),
            LocationSection(
              rows: [
                LocationPlaceRow(
                  icon: AppAssets.crosshair,
                  isHighlighted: true,
                  title: l10n.locationUseCurrent,
                  detail: here?.displayName,
                  isSelected: here != null && isSelected(here),
                  onTap: () => _useCurrent(context, cubit),
                ),
              ],
            ),
            if (state.nearby.isNotEmpty)
              LocationSection(
                label: l10n.locationNearby,
                rows: [
                  for (final place in state.nearby)
                    LocationPlaceRow(
                      icon: AppAssets.location,
                      title: place.name,
                      detail: placeDetail(context, place),
                      isSelected: isSelected(place),
                      onTap: () => cubit.select(place),
                    ),
                ],
              ),
            if (state.recent.isNotEmpty)
              LocationSection(
                label: l10n.locationRecent,
                rows: [
                  for (final place in state.recent)
                    LocationPlaceRow(
                      icon: AppAssets.clock,
                      title: place.name,
                      detail: placeDetail(context, place),
                      isSelected: isSelected(place),
                      onTap: () => cubit.select(place),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
