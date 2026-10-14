import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/add_location_cubit.dart';
import '../cubit/add_location_state.dart';
import '../utils/enums/location_search_status.dart';
import '../utils/place_detail.dart';
import 'location_notice_row.dart';
import 'location_place_row.dart';
import 'location_section.dart';

/// Panel 2: the loader, the places that match what was typed, or why there are none.
class AddLocationResults extends StatelessWidget {
  const AddLocationResults({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AddLocationCubit>();
    return BlocBuilder<AddLocationCubit, AddLocationState>(
      builder: (context, state) {
        if (state.searchStatus == LocationSearchStatus.failed) {
          return ListView(
            children: [
              LocationNoticeRow(
                message: state.isOffline
                    ? l10n.locationOffline
                    : l10n.locationSearchFailed,
              ),
            ],
          );
        }
        // Until the first answer, and while a newer search runs, the last results stay on screen.
        if (state.results.isEmpty) {
          return Center(
            child: Semantics(
              liveRegion: true,
              label: l10n.loading,
              child: PulseLineLoader(
                color: context.appColors.primary,
                width: LocationDimens.loaderWidth,
              ),
            ),
          );
        }
        return ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.cardMargin,
            AppSpacing.s8,
            AppSpacing.cardMargin,
            AppSpacing.s24,
          ),
          children: [
            LocationSection(
              label: l10n.locationResults,
              rows: [
                for (final place in state.results)
                  LocationPlaceRow(
                    icon: AppAssets.location,
                    title: place.name,
                    detail: placeDetail(context, place),
                    query: state.query,
                    isSelected:
                        state.current != null &&
                        state.current == place.displayName,
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
