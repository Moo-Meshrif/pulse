import 'package:flutter/widgets.dart';

import '../error/failures.dart';
import '../notice/notices.dart';
import 'failure_l10n.dart';

extension NoticeContext on BuildContext {
  /// Words [failure] with `Failure.l10n` and shows it as an error notice; does nothing when it is null.
  void showFailure(Failure? failure) => Notices.error(failure?.l10n(this));
}
