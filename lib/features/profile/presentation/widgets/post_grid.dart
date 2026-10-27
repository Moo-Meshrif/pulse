import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/model/profile_grid_item_model.dart';
import '../dimens/profile_dimens.dart';

/// Square tiles, three to a row. [urls] holds the signed picture links by storage path; a tile whose link
/// is not there yet shows its blurhash.
class PostGrid extends StatelessWidget {
  const PostGrid({super.key, required this.items, required this.urls});

  final List<ProfileGridItemModel> items;
  final Map<String, String> urls;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
    sliver: SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ProfileDimens.gridColumns,
        mainAxisSpacing: ProfileDimens.gridGap,
        crossAxisSpacing: ProfileDimens.gridGap,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _Tile(item: item, url: urls[item.thumbPath]);
      },
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item, required this.url});

  final ProfileGridItemModel item;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = AppBlurhash(hash: item.firstBlurhash);
    final url = this.url;
    return Semantics(
      button: true,
      label: context.l10n.profilePostA11y,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => AppNavigator.push(
          context,
          AppRoutes.postPage(item.id!),
          rootNavigator: true,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ProfileDimens.gridRadius),
          child: url == null
              ? placeholder
              : AppImage.network(
                  url,
                  cacheKey: item.thumbPath,
                  fit: BoxFit.cover,
                  cacheWidth: 400,
                  placeholder: placeholder,
                  errorBuilder: (_) => placeholder,
                ),
        ),
      ),
    );
  }
}
