import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../utils/enums/create_option.dart';
import 'create_option_row.dart';

/// The sheet the nav bar's "+" opens (docs/specs/control/screens/s1-create-sheet.md): Post and Short.
abstract final class CreateSheet {
  /// The option the user picked, or null when the sheet was dismissed.
  static Future<CreateOption?> show(BuildContext context) =>
      AppBottomSheet.show<CreateOption>(
        context,
        title: context.l10n.createTitle,
        child: const _Options(),
      );
}

class _Options extends StatelessWidget {
  const _Options();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final option in CreateOption.values) ...[
        CreateOptionRow(
          option: option,
          onTap: () => AppNavigator.back(context, option),
        ),
        if (option != CreateOption.values.last)
          SizedBox(height: BottomSheetDimens.optionGap),
      ],
    ],
  );
}
