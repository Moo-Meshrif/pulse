import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/add_location_cubit.dart';
import '../cubit/add_location_state.dart';
import '../utils/enums/add_location_content.dart';
import '../widgets/add_location_header.dart';
import '../widgets/add_location_home.dart';
import '../widgets/add_location_results.dart';
import '../widgets/location_empty.dart';
import '../widgets/location_notice_row.dart';
import '../widgets/location_primer.dart';
import '../widgets/location_search_field.dart';

/// The Add location layout (docs/specs/post/screens/s3-add-location.md): header, search, and the panel
/// the state asks for. It reads the permission again when the app comes back from Settings.
class AddLocationView extends StatefulWidget {
  const AddLocationView({super.key});

  @override
  State<AddLocationView> createState() => _AddLocationViewState();
}

class _AddLocationViewState extends State<AddLocationView> {
  late final AppLifecycleListener _lifecycle;

  AddLocationCubit get _cubit => context.read<AddLocationCubit>();

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _recheckAccess);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _recheckAccess() => _cubit.recheckAccess();

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    return AppPage(
      showTopBar: false,
      backgroundColor: context.appColors.background,
      child: Column(
        children: [
          BlocSelector<AddLocationCubit, AddLocationState, bool>(
            selector: (state) => state.current != null,
            builder: (context, hasLocation) => AddLocationHeader(
              onBack: () => AppNavigator.back(context),
              onRemove: hasLocation ? cubit.remove : null,
            ),
          ),
          const _SearchArea(),
          const Expanded(child: _Panel()),
        ],
      ),
    );
  }
}

class _SearchArea extends StatelessWidget {
  const _SearchArea();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddLocationCubit>();
    return BlocSelector<
      AddLocationCubit,
      AddLocationState,
      ({bool visible, bool autofocus, bool enabled})
    >(
      selector: (state) => (
        visible:
            AddLocationContent.resolve(state) != AddLocationContent.primer &&
            !state.isLoading,
        autofocus: state.shouldAutofocusSearch,
        enabled: !state.isOffline,
      ),
      builder: (context, search) => search.visible
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
              child: Column(
                children: [
                  LocationSearchField(
                    onChanged: cubit.queryChanged,
                    autofocus: search.autofocus,
                    enabled: search.enabled,
                  ),
                  if (!search.enabled)
                    LocationNoticeRow(message: context.l10n.locationOffline),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<AddLocationCubit, AddLocationState, AddLocationContent>(
        selector: AddLocationContent.resolve,
        builder: (context, content) => switch (content) {
          AddLocationContent.loading => const AppLoadingView(),
          AddLocationContent.primer => const LocationPrimer(),
          AddLocationContent.search => const AddLocationResults(),
          AddLocationContent.noResults => const LocationEmpty(),
          AddLocationContent.home => const AddLocationHome(),
        },
      );
}
